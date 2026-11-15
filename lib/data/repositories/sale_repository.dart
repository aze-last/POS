import 'package:drift/drift.dart';

import '../../domain/models/weight.dart';
import '../../domain/services/pricing_calculator.dart';
import '../database/app_database.dart';

/// Exception thrown when attempting to edit or void a sale on a locked payout day.
class SaleModificationLockedException implements Exception {
  final String message;
  const SaleModificationLockedException(this.message);

  @override
  String toString() => message;
}

/// Input data for an itemized line when completing a sale.
class SaleLineInput {
  final int productId;
  final String productName;
  final Weight weight;
  final int pricePerKgCentavos;
  final int capitalPerKgCentavos;

  const SaleLineInput({
    required this.productId,
    required this.productName,
    required this.weight,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
  });

  int get lineValueCentavos => PricingCalculator.computeLineValue(
    grams: weight.grams,
    pricePerKgCentavos: pricePerKgCentavos,
  );

  int get lineCapitalCentavos => PricingCalculator.computeLineCapital(
    grams: weight.grams,
    capitalPerKgCentavos: capitalPerKgCentavos,
  );
}

/// Result returned after atomically completing a sale.
class CompletedSaleResult {
  final Sale sale;
  final List<SaleItem> items;
  final int discountCentavos;

  const CompletedSaleResult({
    required this.sale,
    required this.items,
    required this.discountCentavos,
  });
}

/// Aggregated sale model including items, calculated capital cost, and net profit.
class SaleWithDetails {
  final Sale sale;
  final List<SaleItem> items;

  const SaleWithDetails({required this.sale, required this.items});

  /// Total capital cost of sold items computed from snapshotted capital per kg.
  int get totalCapitalCentavos => items.fold<int>(
    0,
    (sum, item) =>
        sum +
        PricingCalculator.computeLineCapital(
          grams: item.grams,
          capitalPerKgCentavos: item.capitalPerKgCentavos,
        ),
  );

  /// Discount given on this sale (Exact - Charged).
  int get discountCentavos => sale.exactTotalCentavos > sale.chargedCentavos
      ? sale.exactTotalCentavos - sale.chargedCentavos
      : 0;

  /// Sale margin profit: Charged amount minus snapshotted capital cost.
  int get profitCentavos => sale.chargedCentavos - totalCapitalCentavos;
}

/// Repository responsible for completing, viewing, voiding, and safeguarding sales.
class SaleRepository {
  final AppDatabase _db;

  SaleRepository(this._db);

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  /// Checks if a given day's payout is locked.
  Future<bool> isDayLocked(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    final lockedPayout =
        await (_db.select(_db.payouts)..where(
              (p) =>
                  p.date.isBiggerOrEqualValue(start) &
                  p.date.isSmallerOrEqualValue(end) &
                  p.locked.equals(true),
            ))
            .get();

    return lockedPayout.isNotEmpty;
  }

  /// Reopens a locked day by setting locked = false on its payout.
  Future<void> reopenDay(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    await (_db.update(_db.payouts)..where(
          (p) =>
              p.date.isBiggerOrEqualValue(start) &
              p.date.isSmallerOrEqualValue(end),
        ))
        .write(const PayoutsCompanion(locked: Value(false)));
  }

  /// Atomically completes a sale in a single database transaction.
  Future<CompletedSaleResult> completeSale({
    required List<SaleLineInput> lines,
    required int chargedCentavos,
    required int paidCentavos,
    DateTime? createdAt,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('Cannot complete a sale with zero items');
    }
    if (chargedCentavos <= 0) {
      throw ArgumentError.value(
        chargedCentavos,
        'chargedCentavos',
        'Amount to charge must be greater than 0',
      );
    }
    if (paidCentavos < chargedCentavos) {
      throw ArgumentError.value(
        paidCentavos,
        'paidCentavos',
        'Amount paid must be greater than or equal to amount charged',
      );
    }

    final exactTotal = lines.fold<int>(
      0,
      (sum, line) => sum + line.lineValueCentavos,
    );
    final changeCentavos = paidCentavos - chargedCentavos;
    final discountCentavos = exactTotal > chargedCentavos
        ? exactTotal - chargedCentavos
        : 0;

    return _db.transaction(() async {
      final saleId = await _db
          .into(_db.sales)
          .insert(
            SalesCompanion.insert(
              createdAt: createdAt ?? DateTime.now(),
              exactTotalCentavos: exactTotal,
              chargedCentavos: chargedCentavos,
              paidCentavos: paidCentavos,
              changeCentavos: changeCentavos,
              voided: const Value(false),
            ),
          );

      final insertedItems = <SaleItem>[];
      for (final line in lines) {
        final itemId = await _db
            .into(_db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: line.productId,
                productNameSnapshot: line.productName,
                grams: line.weight.grams,
                pricePerKgCentavos: line.pricePerKgCentavos,
                capitalPerKgCentavos: line.capitalPerKgCentavos,
              ),
            );

        final item = await (_db.select(
          _db.saleItems,
        )..where((i) => i.id.equals(itemId))).getSingle();
        insertedItems.add(item);
      }

      final sale = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      return CompletedSaleResult(
        sale: sale,
        items: insertedItems,
        discountCentavos: discountCentavos,
      );
    });
  }

  /// Voids a sale with audit protection and day-lock verification.
  ///
  /// Keeps the database row, sets voided = true, and preserves line items.
  /// Throws SaleModificationLockedException if the day's payout is locked.
  Future<void> voidSale(int saleId) async {
    final sale = await (_db.select(
      _db.sales,
    )..where((s) => s.id.equals(saleId))).getSingleOrNull();
    if (sale == null) {
      throw ArgumentError('Sale with id $saleId not found');
    }

    // Verify if day is locked
    if (await isDayLocked(sale.createdAt)) {
      throw const SaleModificationLockedException(
        'This day payout is locked. Reopen the day first to void or edit sales.',
      );
    }

    await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
      const SalesCompanion(voided: Value(true)),
    );
  }

  /// Retrieves a sale by ID including its snapshotted items.
  Future<CompletedSaleResult?> getSaleById(int saleId) async {
    final sale = await (_db.select(
      _db.sales,
    )..where((s) => s.id.equals(saleId))).getSingleOrNull();
    if (sale == null) return null;

    final items = await (_db.select(
      _db.saleItems,
    )..where((i) => i.saleId.equals(saleId))).get();
    final discount = sale.exactTotalCentavos > sale.chargedCentavos
        ? sale.exactTotalCentavos - sale.chargedCentavos
        : 0;

    return CompletedSaleResult(
      sale: sale,
      items: items,
      discountCentavos: discount,
    );
  }

  /// Retrieves sales with details, optionally filtered by a specific calendar day.
  Future<List<SaleWithDetails>> getSalesWithDetails({
    DateTime? dateFilter,
  }) async {
    var query = _db.select(_db.sales);

    if (dateFilter != null) {
      final start = _startOfDay(dateFilter);
      final end = _endOfDay(dateFilter);
      query = query
        ..where(
          (s) =>
              s.createdAt.isBiggerOrEqualValue(start) &
              s.createdAt.isSmallerOrEqualValue(end),
        );
    }

    query = query
      ..orderBy([
        (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
      ]);

    final sales = await query.get();
    final results = <SaleWithDetails>[];

    for (final sale in sales) {
      final items = await (_db.select(
        _db.saleItems,
      )..where((i) => i.saleId.equals(sale.id))).get();
      results.add(SaleWithDetails(sale: sale, items: items));
    }

    return results;
  }

  /// Streams sales with details for real-time reactivity.
  Stream<List<SaleWithDetails>> watchSalesWithDetails({DateTime? dateFilter}) {
    var query = _db.select(_db.sales);

    if (dateFilter != null) {
      final start = _startOfDay(dateFilter);
      final end = _endOfDay(dateFilter);
      query = query
        ..where(
          (s) =>
              s.createdAt.isBiggerOrEqualValue(start) &
              s.createdAt.isSmallerOrEqualValue(end),
        );
    }

    query = query
      ..orderBy([
        (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((sales) async {
      final results = <SaleWithDetails>[];
      for (final sale in sales) {
        final items = await (_db.select(
          _db.saleItems,
        )..where((i) => i.saleId.equals(sale.id))).get();
        results.add(SaleWithDetails(sale: sale, items: items));
      }
      return results;
    });
  }
}
