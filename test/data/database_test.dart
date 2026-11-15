import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('initializes and seeds starter products', () async {
      final products = await db.getAllActiveProducts();
      expect(products.length, equals(6));

      final names = products.map((p) => p.name).toList();
      expect(
        names,
        containsAll([
          'Cardava',
          'Binanggay',
          'Tundan',
          'Sab-a',
          'Mundo',
          'Lube',
        ]),
      );

      for (final p in products) {
        expect(p.defaultPriceCentavos, greaterThan(0));
        expect(p.capitalCentavos, greaterThan(0));
        expect(p.archived, isFalse);
      }
    });

    test('initializes default settings with 30% salary percent', () async {
      final settings = await db.getSettings();
      expect(settings, isNotNull);
      expect(settings.salaryMode, equals('percent'));
      expect(settings.salaryPercentBasisPoints, equals(3000)); // 30%
    });

    test('transaction rolls back on error', () async {
      final initialSales = await db.select(db.sales).get();
      expect(initialSales.isEmpty, isTrue);

      try {
        await db.transaction(() async {
          await db
              .into(db.sales)
              .insert(
                SalesCompanion.insert(
                  createdAt: DateTime.now(),
                  exactTotalCentavos: 3250,
                  chargedCentavos: 3200,
                  paidCentavos: 5000,
                  changeCentavos: 1800,
                ),
              );
          // Deliberate failure inside transaction
          throw Exception('Simulated checkout failure');
        });
      } catch (_) {
        // Expected
      }

      final salesAfterFailedTx = await db.select(db.sales).get();
      expect(
        salesAfterFailedTx.isEmpty,
        isTrue,
        reason: 'Transaction must rollback completely on error',
      );
    });

    test('snapshots price and capital on sale items', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere((p) => p.name == 'Cardava');

      late int saleId;
      await db.transaction(() async {
        saleId = await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                createdAt: DateTime.now(),
                exactTotalCentavos: 3000,
                chargedCentavos: 3000,
                paidCentavos: 3000,
                changeCentavos: 0,
              ),
            );

        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: cardava.id,
                productNameSnapshot: cardava.name,
                grams: 1000,
                pricePerKgCentavos: cardava.defaultPriceCentavos,
                capitalPerKgCentavos: cardava.capitalCentavos,
              ),
            );
      });

      final items = await (db.select(
        db.saleItems,
      )..where((i) => i.saleId.equals(saleId))).get();
      expect(items.length, equals(1));
      expect(items.first.productNameSnapshot, equals('Cardava'));
      expect(
        items.first.pricePerKgCentavos,
        equals(cardava.defaultPriceCentavos),
      );
      expect(items.first.capitalPerKgCentavos, equals(cardava.capitalCentavos));
    });
  });
}
