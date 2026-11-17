import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/product_repository.dart';

void main() {
  late AppDatabase db;
  late ProductRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ProductRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProductRepository', () {
    test(
      'lists active products in sort order and separates archived',
      () async {
        final active = await repository.getActiveProducts();
        expect(active.map((p) => p.name).toList(), [
          'Cardava',
          'Binanggay',
          'Tundan',
          'Sab-a',
          'Mundo',
          'Lube',
        ]);

        final cardava = active.first;
        await repository.archiveProduct(cardava.id);

        final stillActive = await repository.getActiveProducts();
        expect(stillActive.length, 5);
        expect(stillActive.any((p) => p.id == cardava.id), isFalse);

        final archived = await repository.getArchivedProducts();
        expect(archived.length, 1);
        expect(archived.single.id, cardava.id);
      },
    );

    test('creates a product at the end of the catalog', () async {
      final created = await repository.createProduct(
        name: '  Latundan  ',
        defaultPriceCentavos: 3200,
        capitalCentavos: 2100,
      );

      expect(created.name, 'Latundan');
      expect(created.defaultPriceCentavos, 3200);
      expect(created.capitalCentavos, 2100);
      expect(created.sortOrder, 6);
      expect(created.archived, isFalse);

      final active = await repository.getActiveProducts();
      expect(active.last.id, created.id);
    });

    test('rejects invalid product input', () async {
      await expectLater(
        repository.createProduct(
          name: '   ',
          defaultPriceCentavos: 3000,
          capitalCentavos: 2000,
        ),
        throwsA(isA<ProductValidationException>()),
      );

      await expectLater(
        repository.createProduct(
          name: 'Saba',
          defaultPriceCentavos: 0,
          capitalCentavos: 2000,
        ),
        throwsA(isA<ProductValidationException>()),
      );

      await expectLater(
        repository.createProduct(
          name: 'Saba',
          defaultPriceCentavos: 3000,
          capitalCentavos: -1,
        ),
        throwsA(isA<ProductValidationException>()),
      );
    });

    test('rejects duplicate active names case-insensitively', () async {
      await expectLater(
        repository.createProduct(
          name: 'cardava',
          defaultPriceCentavos: 3000,
          capitalCentavos: 2000,
        ),
        throwsA(
          isA<ProductValidationException>().having(
            (e) => e.message,
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test(
      'updates a product and writes capital history only on change',
      () async {
        final cardava = (await repository.getActiveProducts()).first;

        final updated = await repository.updateProduct(
          id: cardava.id,
          name: 'Cardava Premium',
          defaultPriceCentavos: 3100,
          capitalCentavos: 2100,
        );

        expect(updated.name, 'Cardava Premium');
        expect(updated.defaultPriceCentavos, 3100);
        expect(updated.capitalCentavos, 2100);

        var history = await repository.getCapitalHistory(cardava.id);
        expect(history.length, 1);
        expect(history.single.oldCentavos, 2000);
        expect(history.single.newCentavos, 2100);

        // Price-only edit does not add history.
        await repository.updateProduct(
          id: cardava.id,
          name: 'Cardava Premium',
          defaultPriceCentavos: 3200,
          capitalCentavos: 2100,
        );
        history = await repository.getCapitalHistory(cardava.id);
        expect(history.length, 1);

        // A second capital change is appended, newest first.
        await repository.updateProduct(
          id: cardava.id,
          name: 'Cardava Premium',
          defaultPriceCentavos: 3200,
          capitalCentavos: 2250,
        );
        history = await repository.getCapitalHistory(cardava.id);
        expect(history.length, 2);
        expect(history.first.oldCentavos, 2100);
        expect(history.first.newCentavos, 2250);
        expect(history.last.oldCentavos, 2000);
        expect(history.last.newCentavos, 2100);
      },
    );

    test('rejects renaming to another active product name', () async {
      final products = await repository.getActiveProducts();
      final cardava = products.first;
      final binanggay = products[1];

      await expectLater(
        repository.updateProduct(
          id: cardava.id,
          name: binanggay.name.toUpperCase(),
          defaultPriceCentavos: cardava.defaultPriceCentavos,
          capitalCentavos: cardava.capitalCentavos,
        ),
        throwsA(isA<ProductValidationException>()),
      );
    });

    test('capital changes never rewrite past sale snapshots', () async {
      final cardava = (await repository.getActiveProducts()).first;

      final saleId = await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              createdAt: DateTime(2026, 1, 10),
              exactTotalCentavos: 3250,
              chargedCentavos: 3250,
              paidCentavos: 5000,
              changeCentavos: 1750,
            ),
          );
      await db
          .into(db.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              saleId: saleId,
              productId: cardava.id,
              productNameSnapshot: cardava.name,
              grams: 1300,
              pricePerKgCentavos: 2500,
              capitalPerKgCentavos: cardava.capitalCentavos,
            ),
          );

      await repository.updateProduct(
        id: cardava.id,
        name: 'Cardava',
        defaultPriceCentavos: 3500,
        capitalCentavos: 2800,
      );

      final item = await db.select(db.saleItems).getSingle();
      expect(item.pricePerKgCentavos, 2500);
      expect(item.capitalPerKgCentavos, 2000);
      expect(item.productNameSnapshot, 'Cardava');
    });

    test('archives and restores a product', () async {
      final cardava = (await repository.getActiveProducts()).first;

      await repository.archiveProduct(cardava.id);
      expect((await repository.getArchivedProducts()).single.id, cardava.id);

      await repository.restoreProduct(cardava.id);
      expect((await repository.getArchivedProducts()), isEmpty);
      final active = await repository.getActiveProducts();
      final restored = active.firstWhere((p) => p.id == cardava.id);
      expect(restored.id, cardava.id);
      expect(restored.archived, isFalse);
      expect(active.last.id, cardava.id);
    });

    test('restore rejects a name already used by an active product', () async {
      final cardava = (await repository.getActiveProducts()).first;
      await repository.archiveProduct(cardava.id);

      await repository.createProduct(
        name: 'Cardava',
        defaultPriceCentavos: 3000,
        capitalCentavos: 2000,
      );

      await expectLater(
        repository.restoreProduct(cardava.id),
        throwsA(isA<ProductValidationException>()),
      );
    });

    test('reorders active products and rejects invalid lists', () async {
      final active = await repository.getActiveProducts();
      final reversedIds = active.reversed.map((p) => p.id).toList();

      await repository.reorderProducts(reversedIds);

      final reordered = await repository.getActiveProducts();
      expect(reordered.map((p) => p.id).toList(), reversedIds);
      expect(reordered.map((p) => p.sortOrder).toList(), [0, 1, 2, 3, 4, 5]);

      await expectLater(
        repository.reorderProducts([active.first.id, active.first.id]),
        throwsA(isA<ProductValidationException>()),
      );

      await expectLater(
        repository.reorderProducts([active.first.id]),
        throwsA(isA<ProductValidationException>()),
      );
    });
  });
}
