import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/services/sync_service.dart';

void main() {
  late AppDatabase db;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    syncService = SyncService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncService Offline-First Engine Tests', () {
    test('reports disabled status when Supabase is unconfigured', () async {
      expect(syncService.isConfigured, isFalse);
      final state = syncService.currentState;
      expect(state.status, equals(SyncStatus.disabled));
      expect(state.isConfigured, isFalse);
    });

    test('generates valid RFC-4122 v4 UUIDs', () {
      final uuid1 = syncService.generateUuid();
      final uuid2 = syncService.generateUuid();

      expect(uuid1, isNotEmpty);
      expect(uuid2, isNotEmpty);
      expect(uuid1, isNot(equals(uuid2)));

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(uuidRegex.hasMatch(uuid1), isTrue);
      expect(uuidRegex.hasMatch(uuid2), isTrue);
    });

    test('enqueueOutbox writes into outboxItems table', () async {
      final uuid = syncService.generateUuid();
      await syncService.enqueueOutbox(
        entityType: 'products',
        entitySyncId: uuid,
        action: 'upsert',
        payload: {
          'id': uuid,
          'name': 'Cardava',
          'default_price_centavos': 3000,
          'capital_centavos': 2000,
        },
      );

      final items = await db.select(db.outboxItems).get();
      expect(items.length, equals(1));
      expect(items.first.entityType, equals('products'));
      expect(items.first.entitySyncId, equals(uuid));
      expect(items.first.action, equals('upsert'));
      expect(items.first.payloadJson, contains('Cardava'));
    });

    test('sync returns disabled when client is not available', () async {
      final result = await syncService.sync();
      expect(result.status, equals(SyncStatus.disabled));
    });

    test('backfills missing syncIds across all local tables', () async {
      // Seed starter product and settings
      final prod = await db
          .into(db.products)
          .insertReturning(
            ProductsCompanion.insert(
              name: 'Cardava',
              defaultPriceCentavos: 3000,
              capitalCentavos: 2000,
            ),
          );
      final sale = await db
          .into(db.sales)
          .insertReturning(
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
              saleId: sale.id,
              productId: prod.id,
              productNameSnapshot: 'Cardava',
              grams: 1000,
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          );
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              date: DateTime.now(),
              type: 'other',
              amountCentavos: 5000,
            ),
          );
      await db
          .into(db.restockPurchases)
          .insert(
            RestockPurchasesCompanion.insert(
              date: DateTime.now(),
              amountCentavos: 10000,
            ),
          );
      await db
          .into(db.payouts)
          .insert(
            PayoutsCompanion.insert(
              date: DateTime.now(),
              toParentsCentavos: 5000,
              salaryCentavos: 2000,
              reserveCentavos: 1000,
            ),
          );
      await db.into(db.settings).insert(SettingsCompanion.insert());

      // Verify all tables currently have null syncIds
      expect(prod.syncId, isNull);
      expect(sale.syncId, isNull);

      // Trigger backfill
      await syncService.backfillMissingSyncIds();

      // Verify syncIds are now populated
      final updatedProds = await db.select(db.products).get();
      final updatedSales = await db.select(db.sales).get();
      final updatedItems = await db.select(db.saleItems).get();
      final updatedExpenses = await db.select(db.expenses).get();
      final updatedRestocks = await db.select(db.restockPurchases).get();
      final updatedPayouts = await db.select(db.payouts).get();
      final updatedSettings = await db.select(db.settings).get();

      expect(updatedProds.first.syncId, isNotNull);
      expect(updatedSales.first.syncId, isNotNull);
      expect(updatedItems.first.syncId, isNotNull);
      expect(updatedExpenses.first.syncId, isNotNull);
      expect(updatedRestocks.first.syncId, isNotNull);
      expect(updatedPayouts.first.syncId, isNotNull);
      expect(updatedSettings.first.syncId, isNotNull);
    });
  });
}
