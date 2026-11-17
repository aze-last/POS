import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    CapitalHistory,
    Sales,
    SaleItems,
    SaleEdits,
    Expenses,
    RestockPurchases,
    Payouts,
    Settings,
    OutboxItems,
    SyncStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaults();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await _safeAddColumn(m, sales, sales.editedAt);
          await _safeAddColumn(m, sales, sales.editCount);
          await _safeCreateTable(m, saleEdits);
        }
        if (from < 3) {
          await _safeAddColumn(m, products, products.imagePath);
        }
        if (from < 4) {
          await _safeAddColumn(m, products, products.syncId);
          await _safeAddColumn(m, products, products.updatedAt);
          await _safeAddColumn(m, products, products.deletedAt);

          await _safeAddColumn(m, capitalHistory, capitalHistory.syncId);
          await _safeAddColumn(m, capitalHistory, capitalHistory.updatedAt);

          await _safeAddColumn(m, sales, sales.syncId);
          await _safeAddColumn(m, sales, sales.updatedAt);
          await _safeAddColumn(m, sales, sales.deletedAt);

          await _safeAddColumn(m, saleItems, saleItems.syncId);
          await _safeAddColumn(m, saleItems, saleItems.updatedAt);
          await _safeAddColumn(m, saleItems, saleItems.deletedAt);

          await _safeAddColumn(m, saleEdits, saleEdits.syncId);

          await _safeAddColumn(m, expenses, expenses.syncId);
          await _safeAddColumn(m, expenses, expenses.updatedAt);
          await _safeAddColumn(m, expenses, expenses.deletedAt);

          await _safeAddColumn(m, restockPurchases, restockPurchases.syncId);
          await _safeAddColumn(m, restockPurchases, restockPurchases.updatedAt);
          await _safeAddColumn(m, restockPurchases, restockPurchases.deletedAt);

          await _safeAddColumn(m, payouts, payouts.syncId);
          await _safeAddColumn(m, payouts, payouts.updatedAt);
          await _safeAddColumn(m, payouts, payouts.deletedAt);

          await _safeAddColumn(m, settings, settings.syncId);
          await _safeAddColumn(m, settings, settings.updatedAt);

          await _safeCreateTable(m, outboxItems);
          await _safeCreateTable(m, syncStates);
        }
      },
      beforeOpen: (details) async {
        // Enforce foreign key constraints in SQLite
        await customStatement('PRAGMA foreign_keys = ON;');
        // Indexes on sales.created_at, expenses.date, and sale_edits.sale_id (Spec Section 4)
        await customStatement(
          'CREATE INDEX IF NOT EXISTS sales_created_at_idx ON sales (created_at);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS expenses_date_idx ON expenses (date);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS sale_edits_sale_id_idx ON sale_edits (sale_id);',
        );
      },
    );
  }

  /// Safely adds a column to a table, ignoring if the column already exists.
  /// This prevents failed or partially-applied migrations from crashing on retry.
  Future<void> _safeAddColumn(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    try {
      await m.addColumn(table, column);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('duplicate column name') ||
          msg.contains('already exists')) {
        return;
      }
      rethrow;
    }
  }

  /// Safely creates a table, ignoring if the table already exists.
  Future<void> _safeCreateTable(Migrator m, TableInfo table) async {
    try {
      await m.createTable(table);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already exists')) {
        return;
      }
      rethrow;
    }
  }

  /// Seeds default starter products and initial settings.
  Future<void> _seedDefaults() async {
    // 1. Starter Products (Spec Section 1 & 4)
    // Products sold by kilo. Initial positive prices and capital.
    final starterProducts = [
      ProductsCompanion.insert(
        name: 'Cardava',
        defaultPriceCentavos: 3000, // P30.00/kg
        capitalCentavos: 2000, // P20.00/kg
        sortOrder: const Value(0),
      ),
      ProductsCompanion.insert(
        name: 'Binanggay',
        defaultPriceCentavos: 3500, // P35.00/kg
        capitalCentavos: 2500, // P25.00/kg
        sortOrder: const Value(1),
      ),
      ProductsCompanion.insert(
        name: 'Tundan',
        defaultPriceCentavos: 4000, // P40.00/kg
        capitalCentavos: 3000, // P30.00/kg
        sortOrder: const Value(2),
      ),
      ProductsCompanion.insert(
        name: 'Sab-a',
        defaultPriceCentavos: 3000, // P30.00/kg
        capitalCentavos: 2000, // P20.00/kg
        sortOrder: const Value(3),
      ),
      ProductsCompanion.insert(
        name: 'Mundo',
        defaultPriceCentavos: 3500, // P35.00/kg
        capitalCentavos: 2500, // P25.00/kg
        sortOrder: const Value(4),
      ),
      ProductsCompanion.insert(
        name: 'Lube',
        defaultPriceCentavos: 3000, // P30.00/kg
        capitalCentavos: 2000, // P20.00/kg
        sortOrder: const Value(5),
      ),
    ];

    for (final p in starterProducts) {
      await into(products).insert(p);
    }

    // 2. Default Settings (Spec Section 4 & 6)
    // Default salary: 30% of net profit (3000 basis points)
    await into(settings).insert(
      SettingsCompanion.insert(
        salaryMode: const Value('percent'),
        salaryPercentBasisPoints: const Value(3000),
        fixedDailySalaryCentavos: const Value(0),
      ),
    );
  }

  // --- Common Database Queries ---

  /// Retrieves all unarchived products ordered by sort_order.
  Future<List<Product>> getAllActiveProducts() {
    return (select(products)
          ..where((p) => p.archived.equals(false))
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .get();
  }

  /// Retrieves the single application settings record.
  Future<Setting> getSettings() {
    return select(settings).getSingle();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_banana.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
