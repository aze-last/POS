import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Aggregated financial ledger summarizing restock funding and repayments to parents.
class ParentsBalanceLedger {
  final int totalRestockSpendCentavos;
  final int totalReturnedToParentsCentavos;

  const ParentsBalanceLedger({
    required this.totalRestockSpendCentavos,
    required this.totalReturnedToParentsCentavos,
  });

  /// Running balance owed to parents (Restock spend minus returned payouts).
  int get outstandingBalanceCentavos =>
      totalRestockSpendCentavos - totalReturnedToParentsCentavos;
}

/// Repository responsible for tracking restock purchases and running balance with parents.
class RestockRepository {
  final AppDatabase _db;

  RestockRepository(this._db);

  /// Records a purchase of bananas funded by parents.
  Future<int> addRestockPurchase({
    required DateTime date,
    required int amountCentavos,
    String? note,
  }) async {
    if (amountCentavos <= 0) {
      throw ArgumentError.value(
        amountCentavos,
        'amountCentavos',
        'Amount must be greater than 0',
      );
    }

    return _db
        .into(_db.restockPurchases)
        .insert(
          RestockPurchasesCompanion.insert(
            date: date,
            amountCentavos: amountCentavos,
            note: Value(note),
          ),
        );
  }

  /// Deletes a restock purchase entry by ID.
  /// Throws [StateError] if the purchase belongs to a date whose payout is locked.
  Future<void> deleteRestockPurchase(int id) async {
    final purchase = await (_db.select(
      _db.restockPurchases,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (purchase == null) return;

    final start = DateTime(
      purchase.date.year,
      purchase.date.month,
      purchase.date.day,
    );
    final end = DateTime(
      purchase.date.year,
      purchase.date.month,
      purchase.date.day,
      23,
      59,
      59,
      999,
    );
    final lockedPayout =
        await (_db.select(_db.payouts)..where(
              (p) =>
                  p.date.isBiggerOrEqualValue(start) &
                  p.date.isSmallerOrEqualValue(end) &
                  p.locked.equals(true),
            ))
            .getSingleOrNull();

    if (lockedPayout != null) {
      throw StateError(
        'Cannot delete restock purchase for locked day ${purchase.date}',
      );
    }

    await (_db.delete(
      _db.restockPurchases,
    )..where((r) => r.id.equals(id))).go();
  }

  /// Retrieves all restock purchases, newest first.
  Future<List<RestockPurchase>> getAllRestockPurchases() {
    return (_db.select(_db.restockPurchases)..orderBy([
          (r) => OrderingTerm(expression: r.date, mode: OrderingMode.desc),
          (r) => OrderingTerm(expression: r.id, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Streams all restock purchases.
  Stream<List<RestockPurchase>> watchAllRestockPurchases() {
    return (_db.select(_db.restockPurchases)..orderBy([
          (r) => OrderingTerm(expression: r.date, mode: OrderingMode.desc),
          (r) => OrderingTerm(expression: r.id, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  /// Computes the sum of all restock purchases.
  Future<int> getTotalRestockSpendCentavos() async {
    final purchases = await _db.select(_db.restockPurchases).get();
    return purchases.fold<int>(0, (sum, p) => sum + p.amountCentavos);
  }

  /// Computes total returned to parents from locked payouts.
  Future<int> getTotalReturnedToParentsCentavos() async {
    final lockedPayouts = await (_db.select(
      _db.payouts,
    )..where((p) => p.locked.equals(true))).get();
    return lockedPayouts.fold<int>(0, (sum, p) => sum + p.toParentsCentavos);
  }

  /// Retrieves the running parents balance ledger.
  Future<ParentsBalanceLedger> getParentsBalanceLedger() async {
    final restock = await getTotalRestockSpendCentavos();
    final returned = await getTotalReturnedToParentsCentavos();

    return ParentsBalanceLedger(
      totalRestockSpendCentavos: restock,
      totalReturnedToParentsCentavos: returned,
    );
  }

  /// Streams the running parents balance ledger reactively.
  Stream<ParentsBalanceLedger> watchParentsBalanceLedger() {
    return _db.select(_db.restockPurchases).watch().asyncMap((_) async {
      return getParentsBalanceLedger();
    });
  }
}
