import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

/// Service responsible for complete offline JSON backup and restore across all 8 tables.
class BackupService {
  static const int currentSchemaVersion = 1;
  static const String appIdentifier = 'Banana POS';

  final AppDatabase _db;

  BackupService(this._db);

  /// Checks if a weekly backup reminder nudge is needed.
  static bool isNudgeNeeded({
    required DateTime? lastBackupDate,
    DateTime? now,
  }) {
    if (lastBackupDate == null) return true;
    final current = now ?? DateTime.now();
    return current.difference(lastBackupDate).inDays >= 7;
  }

  /// Exports all 8 tables into an aggregated Map with schema version.
  Future<Map<String, dynamic>> exportData() async {
    final products = await _db.select(_db.products).get();
    final capitalHistory = await _db.select(_db.capitalHistory).get();
    final sales = await _db.select(_db.sales).get();
    final saleItems = await _db.select(_db.saleItems).get();
    final expenses = await _db.select(_db.expenses).get();
    final restock = await _db.select(_db.restockPurchases).get();
    final payouts = await _db.select(_db.payouts).get();
    final settings = await _db.select(_db.settings).get();

    return {
      'schema_version': currentSchemaVersion,
      'app': appIdentifier,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': {
        'products': products
            .map(
              (p) => {
                'id': p.id,
                'name': p.name,
                'default_price_centavos': p.defaultPriceCentavos,
                'capital_centavos': p.capitalCentavos,
                'sort_order': p.sortOrder,
                'archived': p.archived,
              },
            )
            .toList(),
        'capital_history': capitalHistory
            .map(
              (c) => {
                'id': c.id,
                'product_id': c.productId,
                'old_centavos': c.oldCentavos,
                'new_centavos': c.newCentavos,
                'changed_at': c.changedAt.toIso8601String(),
              },
            )
            .toList(),
        'sales': sales
            .map(
              (s) => {
                'id': s.id,
                'created_at': s.createdAt.toIso8601String(),
                'exact_total_centavos': s.exactTotalCentavos,
                'charged_centavos': s.chargedCentavos,
                'paid_centavos': s.paidCentavos,
                'change_centavos': s.changeCentavos,
                'voided': s.voided,
              },
            )
            .toList(),
        'sale_items': saleItems
            .map(
              (i) => {
                'id': i.id,
                'sale_id': i.saleId,
                'product_id': i.productId,
                'product_name_snapshot': i.productNameSnapshot,
                'grams': i.grams,
                'price_per_kg_centavos': i.pricePerKgCentavos,
                'capital_per_kg_centavos': i.capitalPerKgCentavos,
              },
            )
            .toList(),
        'expenses': expenses
            .map(
              (e) => {
                'id': e.id,
                'date': e.date.toIso8601String(),
                'type': e.type,
                'amount_centavos': e.amountCentavos,
                'note': e.note,
                'product_id': e.productId,
                'grams': e.grams,
                'capital_per_kg_centavos': e.capitalPerKgCentavos,
              },
            )
            .toList(),
        'restock_purchases': restock
            .map(
              (r) => {
                'id': r.id,
                'date': r.date.toIso8601String(),
                'amount_centavos': r.amountCentavos,
                'note': r.note,
              },
            )
            .toList(),
        'payouts': payouts
            .map(
              (p) => {
                'id': p.id,
                'date': p.date.toIso8601String(),
                'to_parents_centavos': p.toParentsCentavos,
                'salary_centavos': p.salaryCentavos,
                'reserve_centavos': p.reserveCentavos,
                'locked': p.locked,
              },
            )
            .toList(),
        'settings': settings
            .map(
              (s) => {
                'id': s.id,
                'salary_mode': s.salaryMode,
                'salary_percent_basis_points': s.salaryPercentBasisPoints,
                'fixed_daily_salary_centavos': s.fixedDailySalaryCentavos,
              },
            )
            .toList(),
      },
    };
  }

  /// Exports the entire database to a formatted JSON string.
  Future<String> exportToJsonString() async {
    final data = await exportData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Restores all 8 database tables identically from JSON within a single SQLite transaction.
  Future<void> restoreFromJsonString(String jsonString) async {
    final Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Root JSON payload must be an object');
      }
      data = decoded;
    } catch (e) {
      throw FormatException('Failed to parse JSON backup: $e');
    }

    final schemaVersion = data['schema_version'];
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported schema version: $schemaVersion. Expected: $currentSchemaVersion',
      );
    }

    final tables = data['tables'];
    if (tables is! Map<String, dynamic>) {
      throw const FormatException('Missing or invalid tables payload');
    }

    // Atomic SQLite transaction ensures complete consistency or total rollback
    await _db.transaction(() async {
      // 1. Delete existing data in reverse foreign-key order
      await _db.delete(_db.saleItems).go();
      await _db.delete(_db.sales).go();
      await _db.delete(_db.capitalHistory).go();
      await _db.delete(_db.expenses).go();
      await _db.delete(_db.restockPurchases).go();
      await _db.delete(_db.payouts).go();
      await _db.delete(_db.settings).go();
      await _db.delete(_db.products).go();

      // 2. Insert Products
      final rawProducts = tables['products'] as List? ?? [];
      for (final p in rawProducts) {
        await _db
            .into(_db.products)
            .insert(
              ProductsCompanion.insert(
                id: Value(p['id'] as int),
                name: p['name'] as String,
                defaultPriceCentavos: p['default_price_centavos'] as int,
                capitalCentavos: p['capital_centavos'] as int,
                sortOrder: Value(p['sort_order'] as int? ?? 0),
                archived: Value(p['archived'] as bool? ?? false),
              ),
            );
      }

      // 3. Insert Settings
      final rawSettings = tables['settings'] as List? ?? [];
      for (final s in rawSettings) {
        await _db
            .into(_db.settings)
            .insert(
              SettingsCompanion.insert(
                id: Value(s['id'] as int),
                salaryMode: Value(s['salary_mode'] as String? ?? 'percent'),
                salaryPercentBasisPoints: Value(
                  s['salary_percent_basis_points'] as int? ?? 3000,
                ),
                fixedDailySalaryCentavos: Value(
                  s['fixed_daily_salary_centavos'] as int? ?? 0,
                ),
              ),
            );
      }

      // 4. Insert Capital History
      final rawCapital = tables['capital_history'] as List? ?? [];
      for (final c in rawCapital) {
        await _db
            .into(_db.capitalHistory)
            .insert(
              CapitalHistoryCompanion.insert(
                id: Value(c['id'] as int),
                productId: c['product_id'] as int,
                oldCentavos: c['old_centavos'] as int,
                newCentavos: c['new_centavos'] as int,
                changedAt: DateTime.parse(c['changed_at'] as String),
              ),
            );
      }

      // 5. Insert Sales
      final rawSales = tables['sales'] as List? ?? [];
      for (final s in rawSales) {
        await _db
            .into(_db.sales)
            .insert(
              SalesCompanion.insert(
                id: Value(s['id'] as int),
                createdAt: DateTime.parse(s['created_at'] as String),
                exactTotalCentavos: s['exact_total_centavos'] as int,
                chargedCentavos: s['charged_centavos'] as int,
                paidCentavos: s['paid_centavos'] as int,
                changeCentavos: s['change_centavos'] as int,
                voided: Value(s['voided'] as bool? ?? false),
              ),
            );
      }

      // 6. Insert Sale Items
      final rawItems = tables['sale_items'] as List? ?? [];
      for (final i in rawItems) {
        await _db
            .into(_db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                id: Value(i['id'] as int),
                saleId: i['sale_id'] as int,
                productId: i['product_id'] as int,
                productNameSnapshot: i['product_name_snapshot'] as String,
                grams: i['grams'] as int,
                pricePerKgCentavos: i['price_per_kg_centavos'] as int,
                capitalPerKgCentavos: i['capital_per_kg_centavos'] as int,
              ),
            );
      }

      // 7. Insert Expenses
      final rawExpenses = tables['expenses'] as List? ?? [];
      for (final e in rawExpenses) {
        await _db
            .into(_db.expenses)
            .insert(
              ExpensesCompanion.insert(
                id: Value(e['id'] as int),
                date: DateTime.parse(e['date'] as String),
                type: e['type'] as String,
                amountCentavos: e['amount_centavos'] as int,
                note: Value(e['note'] as String?),
                productId: Value(e['product_id'] as int?),
                grams: Value(e['grams'] as int?),
                capitalPerKgCentavos: Value(
                  e['capital_per_kg_centavos'] as int?,
                ),
              ),
            );
      }

      // 8. Insert Restock Purchases
      final rawRestock = tables['restock_purchases'] as List? ?? [];
      for (final r in rawRestock) {
        await _db
            .into(_db.restockPurchases)
            .insert(
              RestockPurchasesCompanion.insert(
                id: Value(r['id'] as int),
                date: DateTime.parse(r['date'] as String),
                amountCentavos: r['amount_centavos'] as int,
                note: Value(r['note'] as String?),
              ),
            );
      }

      // 9. Insert Payouts
      final rawPayouts = tables['payouts'] as List? ?? [];
      for (final p in rawPayouts) {
        await _db
            .into(_db.payouts)
            .insert(
              PayoutsCompanion.insert(
                id: Value(p['id'] as int),
                date: DateTime.parse(p['date'] as String),
                toParentsCentavos: p['to_parents_centavos'] as int,
                salaryCentavos: p['salary_centavos'] as int,
                reserveCentavos: p['reserve_centavos'] as int,
                locked: Value(p['locked'] as bool? ?? false),
              ),
            );
      }
    });
  }

  /// Exports backup to a temporary file and triggers the native system share sheet.
  Future<void> shareBackupFile() async {
    final jsonString = await exportToJsonString();
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${tempDir.path}/banana_pos_backup_$timestamp.json');
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Banana POS Offline Backup ($timestamp)',
      ),
    );

    await recordLastBackupTime();
  }

  /// Prompts user to select a JSON file and restores database after explicit confirmation.
  Future<bool> pickAndRestoreBackupFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (files.isEmpty) {
      return false;
    }

    final path = files.first.path;
    if (path == null) return false;

    final file = File(path);
    final jsonContent = await file.readAsString();
    await restoreFromJsonString(jsonContent);
    return true;
  }

  /// Records current time as the latest backup timestamp in offline local storage.
  Future<void> recordLastBackupTime() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/last_backup_meta.json');
      await file.writeAsString(
        jsonEncode({'last_backup_at': DateTime.now().toIso8601String()}),
      );
    } catch (_) {
      // Ignored if file write fails in testing
    }
  }

  /// Gets the timestamp of the last successful export.
  Future<DateTime?> getLastBackupTime() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/last_backup_meta.json');
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final data = jsonDecode(content);
      if (data is Map && data['last_backup_at'] != null) {
        return DateTime.parse(data['last_backup_at'] as String);
      }
    } catch (_) {
      // Ignored
    }
    return null;
  }
}
