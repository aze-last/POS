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
    Expenses,
    RestockPurchases,
    Payouts,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaults();
      },
      beforeOpen: (details) async {
        // Enforce foreign key constraints in SQLite
        await customStatement('PRAGMA foreign_keys = ON;');
        // Indexes on sales.created_at and expenses.date (Spec Section 4)
        await customStatement(
          'CREATE INDEX IF NOT EXISTS sales_created_at_idx ON sales (created_at);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS expenses_date_idx ON expenses (date);',
        );
      },
    );
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
