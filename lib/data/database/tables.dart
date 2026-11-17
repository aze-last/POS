import 'package:drift/drift.dart';

/// Products sold by the kilo.
///
/// Archive products, never hard-delete them (old sales must stay intact).
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get defaultPriceCentavos => integer()();
  IntColumn get capitalCentavos => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// History of capital cost changes per product.
class CapitalHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get oldCentavos => integer()();
  IntColumn get newCentavos => integer()();
  DateTimeColumn get changedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

/// Completed sales transactions.
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get exactTotalCentavos => integer()();
  IntColumn get chargedCentavos => integer()();
  IntColumn get paidCentavos => integer()();
  IntColumn get changeCentavos => integer()();
  BoolColumn get voided => boolean().withDefault(const Constant(false))();
  DateTimeColumn get editedAt => dateTime().nullable()();
  IntColumn get editCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Itemized lines within a sale.
///
/// Every sale item SNAPSHOTS product name, price, and capital at sale time.
/// Past profit is never recomputed from current catalog values.
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productNameSnapshot => text()();
  IntColumn get grams => integer()();
  IntColumn get pricePerKgCentavos => integer()();
  IntColumn get capitalPerKgCentavos => integer()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Audit log of modifications made to sales.
///
/// An immutable, append-only ledger recording full before and after JSON
/// snapshots (in integer centavos and grams) whenever a sale is edited.
class SaleEdits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  IntColumn get saleId => integer().references(Sales, #id)();
  DateTimeColumn get editedAt => dateTime()();
  TextColumn get beforeJson => text()();
  TextColumn get afterJson => text()();
  TextColumn get reason => text().nullable()();
}

/// Daily expenses and losses.
///
/// Types: transport | spoilage | other.
/// Spoilage snapshots product_id, grams, and capital_per_kg_centavos.
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // transport | spoilage | other
  IntColumn get amountCentavos => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  IntColumn get grams => integer().nullable()();
  IntColumn get capitalPerKgCentavos => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Purchases made to restock produce funded by parents.
class RestockPurchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountCentavos => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Daily payout settlement records.
class Payouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get toParentsCentavos => integer()();
  IntColumn get salaryCentavos => integer()();
  IntColumn get reserveCentavos => integer()();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Global application and payout configuration settings.
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  TextColumn get salaryMode =>
      text().withDefault(const Constant('percent'))(); // percent | fixed
  IntColumn get salaryPercentBasisPoints =>
      integer().withDefault(const Constant(3000))(); // 30% = 3000 bps
  IntColumn get fixedDailySalaryCentavos =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

/// Local outbox queue for changes pending push to Supabase.
class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'products', 'capital_history', 'sales', 'sale_items', 'sale_edits', 'expenses', 'restock_purchases', 'payouts', 'settings'
  TextColumn get entitySyncId => text()();
  TextColumn get action => text()(); // 'upsert', 'insert'
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Metadata tracking last synchronization time and status.
class SyncStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get lastSyncStatus =>
      text().nullable()(); // 'idle', 'syncing', 'success', 'error'
  TextColumn get lastErrorMessage => text().nullable()();
}
