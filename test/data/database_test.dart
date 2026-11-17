import 'package:drift/drift.dart' hide isNotNull, isNull;
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

    test('transaction rolls back on error across multiple rows', () async {
      final initialSales = await db.select(db.sales).get();
      final initialItems = await db.select(db.saleItems).get();
      expect(initialSales.isEmpty, isTrue);
      expect(initialItems.isEmpty, isTrue);

      try {
        await db.transaction(() async {
          final saleId = await db
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

          // Write 2nd row (multi-row write invariant)
          await db
              .into(db.saleItems)
              .insert(
                SaleItemsCompanion.insert(
                  saleId: saleId,
                  productId: 1,
                  productNameSnapshot: 'Cardava',
                  grams: 1300,
                  pricePerKgCentavos: 2500,
                  capitalPerKgCentavos: 1800,
                ),
              );

          // Deliberate failure after partial multi-row write
          throw Exception('Simulated checkout failure after line items');
        });
      } catch (_) {
        // Expected
      }

      final salesAfterFailedTx = await db.select(db.sales).get();
      final itemsAfterFailedTx = await db.select(db.saleItems).get();
      expect(
        salesAfterFailedTx.isEmpty,
        isTrue,
        reason: 'First inserted row (sale) must rollback completely on error',
      );
      expect(
        itemsAfterFailedTx.isEmpty,
        isTrue,
        reason:
            'Second inserted row (sale item) must rollback completely on error',
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

    test('schemaVersion is 4 and saleEdits table stores and queries audit snapshots', () async {
      expect(db.schemaVersion, equals(4));

      final saleId = await db
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

      final editId = await db
          .into(db.saleEdits)
          .insert(
            SaleEditsCompanion.insert(
              saleId: saleId,
              editedAt: DateTime.now(),
              beforeJson: '{"charged_centavos":3000}',
              afterJson: '{"charged_centavos":2800}',
              reason: const Value('Loyalty discount'),
            ),
          );

      final edits = await (db.select(
        db.saleEdits,
      )..where((e) => e.saleId.equals(saleId))).get();
      expect(edits.length, equals(1));
      expect(edits.first.id, equals(editId));
      expect(edits.first.reason, equals('Loyalty discount'));
    });

    test('products table supports nullable imagePath field', () async {
      expect(db.schemaVersion, equals(4));

      final prodId = await db
          .into(db.products)
          .insert(
            ProductsCompanion.insert(
              name: 'Photo Banana',
              defaultPriceCentavos: 4000,
              capitalCentavos: 2500,
              sortOrder: const Value(99),
              imagePath: const Value('/local/path/to/img.jpg'),
            ),
          );

      final p = await (db.select(
        db.products,
      )..where((tbl) => tbl.id.equals(prodId))).getSingle();
      expect(p.imagePath, equals('/local/path/to/img.jpg'));
    });

    test('supports sync fields and outboxItems queue', () async {
      expect(db.schemaVersion, equals(4));

      final outboxId = await db
          .into(db.outboxItems)
          .insert(
            OutboxItemsCompanion.insert(
              entityType: 'products',
              entitySyncId: 'test-uuid-1234',
              action: 'upsert',
              payloadJson: '{"name":"Cardava"}',
              createdAt: DateTime.now(),
            ),
          );

      final outboxRows = await db.select(db.outboxItems).get();
      expect(outboxRows.length, equals(1));
      expect(outboxRows.first.id, equals(outboxId));
      expect(outboxRows.first.entitySyncId, equals('test-uuid-1234'));
    });
  });
}
