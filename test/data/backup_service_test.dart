import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/services/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = BackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupService Offline JSON Engine Tests', () {
    test('exports all 8 tables with schema_version and metadata', () async {
      // 1. Products are seeded (6 default varieties)
      // 2. Add capital history
      await db
          .into(db.capitalHistory)
          .insert(
            CapitalHistoryCompanion.insert(
              productId: 1,
              oldCentavos: 1800,
              newCentavos: 2000,
              changedAt: DateTime(2026, 11, 14, 10, 0),
            ),
          );

      // 3. Add a sale
      final saleId = await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              createdAt: DateTime(2026, 11, 15, 12, 0),
              exactTotalCentavos: 3000,
              chargedCentavos: 3000,
              paidCentavos: 3000,
              changeCentavos: 0,
            ),
          );

      // 4. Add sale items
      await db
          .into(db.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              saleId: saleId,
              productId: 1,
              productNameSnapshot: 'Cardava',
              grams: 1000,
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          );

      // 5. Add expenses (transport & spoilage)
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              date: DateTime(2026, 11, 15),
              type: 'transport',
              amountCentavos: 5000,
              note: const Value('Jeepney fare'),
            ),
          );
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              date: DateTime(2026, 11, 15),
              type: 'spoilage',
              amountCentavos: 2000,
              productId: const Value(1),
              grams: const Value(1000),
              capitalPerKgCentavos: const Value(2000),
            ),
          );

      // 6. Add restock purchase
      await db
          .into(db.restockPurchases)
          .insert(
            RestockPurchasesCompanion.insert(
              date: DateTime(2026, 11, 10),
              amountCentavos: 500000,
              note: const Value('Wholesale crates'),
            ),
          );

      // 7. Add payouts
      await db
          .into(db.payouts)
          .insert(
            PayoutsCompanion.insert(
              date: DateTime(2026, 11, 14),
              toParentsCentavos: 300000,
              salaryCentavos: 50000,
              reserveCentavos: 20000,
              locked: const Value(true),
            ),
          );

      // 8. Settings already initialized with default row

      final export = await service.exportData();

      expect(export['schema_version'], BackupService.currentSchemaVersion);
      expect(export['app'], 'Banana POS');
      expect(export['exported_at'], isNotNull);

      final tables = export['tables'] as Map<String, dynamic>;
      expect((tables['products'] as List).length, greaterThanOrEqualTo(6));
      expect((tables['capital_history'] as List).length, 1);
      expect((tables['sales'] as List).length, 1);
      expect((tables['sale_items'] as List).length, 1);
      expect((tables['sale_edits'] as List).length, 0);
      expect((tables['expenses'] as List).length, 2);
      expect((tables['restock_purchases'] as List).length, 1);
      expect((tables['payouts'] as List).length, 1);
      expect((tables['settings'] as List).length, 1);
    });

    test(
      'export then import round-trips to identical data across all 8 tables',
      () async {
        final exportDate = DateTime(2026, 11, 15, 14, 30);

        // Setup rich dataset in db1
        await db
            .into(db.capitalHistory)
            .insert(
              CapitalHistoryCompanion.insert(
                productId: 1,
                oldCentavos: 1800,
                newCentavos: 2000,
                changedAt: exportDate,
              ),
            );

        final saleId = await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                createdAt: exportDate,
                exactTotalCentavos: 6000,
                chargedCentavos: 5500,
                paidCentavos: 6000,
                changeCentavos: 500,
                voided: const Value(false),
              ),
            );

        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: 1,
                productNameSnapshot: 'Cardava',
                grams: 2000,
                pricePerKgCentavos: 3000,
                capitalPerKgCentavos: 2000,
              ),
            );

        await db
            .into(db.expenses)
            .insert(
              ExpensesCompanion.insert(
                date: exportDate,
                type: 'spoilage',
                amountCentavos: 3000,
                productId: const Value(1),
                grams: const Value(1500),
                capitalPerKgCentavos: const Value(2000),
                note: const Value('Bruised'),
              ),
            );

        await db
            .into(db.restockPurchases)
            .insert(
              RestockPurchasesCompanion.insert(
                date: exportDate,
                amountCentavos: 1000000,
                note: const Value('Farmer batch'),
              ),
            );

        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: exportDate,
                toParentsCentavos: 400000,
                salaryCentavos: 80000,
                reserveCentavos: 20000,
                locked: const Value(true),
              ),
            );

        await db
            .into(db.saleEdits)
            .insert(
              SaleEditsCompanion.insert(
                saleId: saleId,
                editedAt: exportDate,
                beforeJson: '{"charged_centavos":6000}',
                afterJson: '{"charged_centavos":5500}',
                reason: const Value('Customer discount'),
              ),
            );

        // Export to JSON string
        final jsonString = await service.exportToJsonString();
        expect(jsonString.isNotEmpty, isTrue);

        // Create a fresh target database
        final targetDb = AppDatabase(NativeDatabase.memory());
        final targetService = BackupService(targetDb);

        try {
          // Restore from JSON
          await targetService.restoreFromJsonString(jsonString);

          // Verify Products
          final targetProducts = await targetDb.select(targetDb.products).get();
          expect(targetProducts.length, 6);

          // Verify Capital History
          final targetHistory = await targetDb
              .select(targetDb.capitalHistory)
              .get();
          expect(targetHistory.length, 1);
          expect(targetHistory.first.newCentavos, 2000);

          // Verify Sales & Items
          final targetSales = await targetDb.select(targetDb.sales).get();
          expect(targetSales.length, 1);
          expect(targetSales.first.chargedCentavos, 5500);

          final targetItems = await targetDb.select(targetDb.saleItems).get();
          expect(targetItems.length, 1);
          expect(targetItems.first.grams, 2000);
          expect(targetItems.first.productNameSnapshot, 'Cardava');

          // Verify Sale Edits
          final targetEdits = await targetDb.select(targetDb.saleEdits).get();
          expect(targetEdits.length, 1);
          expect(targetEdits.first.reason, 'Customer discount');

          // Verify Expenses
          final targetExpenses = await targetDb.select(targetDb.expenses).get();
          expect(targetExpenses.length, 1);
          expect(targetExpenses.first.type, 'spoilage');
          expect(targetExpenses.first.grams, 1500);

          // Verify Restock
          final targetRestock = await targetDb
              .select(targetDb.restockPurchases)
              .get();
          expect(targetRestock.length, 1);
          expect(targetRestock.first.amountCentavos, 1000000);

          // Verify Payouts
          final targetPayouts = await targetDb.select(targetDb.payouts).get();
          expect(targetPayouts.length, 1);
          expect(targetPayouts.first.locked, isTrue);
        } finally {
          await targetDb.close();
        }
      },
    );

    test('restoreFromJsonString seamlessly imports legacy schema_version 1 backups', () async {
      final legacyJson = jsonEncode({
        'schema_version': 1,
        'app': 'Banana POS',
        'exported_at': '2026-11-15T10:00:00.000',
        'tables': {
          'products': [
            {
              'id': 1,
              'name': 'Cardava',
              'default_price_centavos': 3000,
              'capital_centavos': 2000,
              'sort_order': 0,
              'archived': false,
            },
          ],
          'settings': [
            {
              'id': 1,
              'salary_mode': 'percent',
              'salary_percent_basis_points': 3000,
              'fixed_daily_salary_centavos': 0,
            },
          ],
          'capital_history': [],
          'sales': [
            {
              'id': 1,
              'created_at': '2026-11-15T12:00:00.000',
              'exact_total_centavos': 3000,
              'charged_centavos': 3000,
              'paid_centavos': 3000,
              'change_centavos': 0,
              'voided': false,
            },
          ],
          'sale_items': [
            {
              'id': 1,
              'sale_id': 1,
              'product_id': 1,
              'product_name_snapshot': 'Cardava',
              'grams': 1000,
              'price_per_kg_centavos': 3000,
              'capital_per_kg_centavos': 2000,
            },
          ],
          'expenses': [],
          'restock_purchases': [],
          'payouts': [],
        },
      });

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetService = BackupService(targetDb);

      try {
        await targetService.restoreFromJsonString(legacyJson);

        final sales = await targetDb.select(targetDb.sales).get();
        expect(sales.length, 1);
        expect(sales.first.editCount, 0);
        expect(sales.first.editedAt == null, isTrue);

        final edits = await targetDb.select(targetDb.saleEdits).get();
        expect(edits.isEmpty, isTrue);
      } finally {
        await targetDb.close();
      }
    });

    test('restoreFromJsonString seamlessly imports legacy schema_version 1 backups', () async {
      final legacyJson = jsonEncode({
        'schema_version': 1,
        'app': 'Banana POS',
        'exported_at': '2026-11-15T10:00:00.000',
        'tables': {
          'products': [
            {
              'id': 1,
              'name': 'Cardava',
              'default_price_centavos': 3000,
              'capital_centavos': 2000,
              'sort_order': 0,
              'archived': false,
            },
          ],
          'settings': [
            {
              'id': 1,
              'salary_mode': 'percent',
              'salary_percent_basis_points': 3000,
              'fixed_daily_salary_centavos': 0,
            },
          ],
          'capital_history': [],
          'sales': [
            {
              'id': 1,
              'created_at': '2026-11-15T12:00:00.000',
              'exact_total_centavos': 3000,
              'charged_centavos': 3000,
              'paid_centavos': 3000,
              'change_centavos': 0,
              'voided': false,
            },
          ],
          'sale_items': [
            {
              'id': 1,
              'sale_id': 1,
              'product_id': 1,
              'product_name_snapshot': 'Cardava',
              'grams': 1000,
              'price_per_kg_centavos': 3000,
              'capital_per_kg_centavos': 2000,
            },
          ],
          'expenses': [],
          'restock_purchases': [],
          'payouts': [],
        },
      });

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetService = BackupService(targetDb);

      try {
        await targetService.restoreFromJsonString(legacyJson);

        final sales = await targetDb.select(targetDb.sales).get();
        expect(sales.length, 1);
        expect(sales.first.editCount, 0);
        expect(sales.first.editedAt == null, isTrue);

        final edits = await targetDb.select(targetDb.saleEdits).get();
        expect(edits.isEmpty, isTrue);
      } finally {
        await targetDb.close();
      }
    });

    test('restoreFromJsonString rejects invalid schema_version or corrupted JSON without modifying database', () async {
      final initialProducts = await db.select(db.products).get();
      final countBefore = initialProducts.length;

      // 1. Corrupted JSON
      expect(
        () => service.restoreFromJsonString('NOT_VALID_JSON{'),
        throwsFormatException,
      );

      // 2. Unsupported schema version
      final invalidVersionJson = jsonEncode({
        'schema_version': 99,
        'app': 'Banana POS',
        'tables': {},
      });
      expect(
        () => service.restoreFromJsonString(invalidVersionJson),
        throwsA(isA<FormatException>()),
      );

      // 3. Missing tables payload
      final missingTablesJson = jsonEncode({
        'schema_version': 1,
        'app': 'Banana POS',
      });
      expect(
        () => service.restoreFromJsonString(missingTablesJson),
        throwsA(isA<FormatException>()),
      );

      // Database data remains completely untouched
      final productsAfter = await db.select(db.products).get();
      expect(productsAfter.length, countBefore);
    });

    test(
      'backup nudge returns true if last backup > 7 days or never performed',
      () {
        final now = DateTime(2026, 11, 16);

        // Never backed up
        expect(
          BackupService.isNudgeNeeded(lastBackupDate: null, now: now),
          isTrue,
        );

        // Backed up 3 days ago -> No nudge
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        expect(
          BackupService.isNudgeNeeded(lastBackupDate: threeDaysAgo, now: now),
          isFalse,
        );

        // Backed up 7 days ago -> Nudge
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        expect(
          BackupService.isNudgeNeeded(lastBackupDate: sevenDaysAgo, now: now),
          isTrue,
        );

        // Backed up 10 days ago -> Nudge
        final tenDaysAgo = now.subtract(const Duration(days: 10));
        expect(
          BackupService.isNudgeNeeded(lastBackupDate: tenDaysAgo, now: now),
          isTrue,
        );
      },
    );
  });
}
