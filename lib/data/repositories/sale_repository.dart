import 'dart:convert';

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

/// Input data for an itemized line when completing or editing a sale.
class SaleLineInput {
  final int productId;
  final String productName;
  final Weight weight;
  final int pricePerKgCentavos;
  final int capitalPerKgCentavos;
  final int? originalItemId;

  const SaleLineInput({
    required this.productId,
    required this.productName,
    required this.weight,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
    this.originalItemId,
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

  /// Voids a sale with audit protection and day-lock verification inside a single transaction.
  ///
  /// Keeps the database row, sets voided = true, and preserves line items.
  /// Throws SaleModificationLockedException if the day's payout is locked.
  Future<void> voidSale(int saleId) async {
    await _db.transaction(() async {
      final sale = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingleOrNull();
      if (sale == null) {
        throw ArgumentError('Sale with id $saleId not found');
      }

      // Verify if day is locked inside transaction to prevent race conditions
      if (await isDayLocked(sale.createdAt)) {
        throw const SaleModificationLockedException(
          'This day payout is locked. Reopen the day first to void or edit sales.',
        );
      }

      await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
        const SalesCompanion(voided: Value(true)),
      );
    });
  }

  /// Edits an existing sale atomically in a single transaction.
  ///
  /// Capital snapshot rules (Spec Section 4 & 9):
  /// - Line unchanged in product: KEEP its original capital_per_kg snapshot, even if grams or price changed.
  /// - Line with a changed product, or a newly added line: use that product's CURRENT capital per kg.
  /// - Never recompute old profit from live capital for untouched lines.
  ///
  /// Audit trail:
  /// - Creates an immutable row in sale_edits with full before_json and after_json.
  /// - Updates sales.edited_at and increments sales.edit_count.
  /// - Throws SaleModificationLockedException if the day's payout is locked.
  /// - Throws StateError if the sale is voided.
  Future<CompletedSaleResult> editSale({
    required int saleId,
    required List<SaleLineInput> newLines,
    required int chargedCentavos,
    required int paidCentavos,
    String? reason,
  }) async {
    return _db.transaction(() async {
      final sale = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingleOrNull();
      if (sale == null) {
        throw ArgumentError('Sale with id $saleId not found');
      }

      if (sale.voided) {
        throw StateError('Voided sales cannot be edited');
      }

      if (await isDayLocked(sale.createdAt)) {
        throw const SaleModificationLockedException(
          'This day is paid out. Reopen it first.',
        );
      }

      if (newLines.isEmpty) {
        throw ArgumentError(
          'Cannot edit sale to have 0 lines. Void the sale instead.',
        );
      }

      for (final line in newLines) {
        if (line.weight.grams <= 0) {
          throw ArgumentError('Line grams must be > 0');
        }
        if (line.pricePerKgCentavos <= 0) {
          throw ArgumentError('Line price per kg must be > 0');
        }
      }

      if (chargedCentavos <= 0) {
        throw ArgumentError('Amount charged must be > 0');
      }

      if (paidCentavos < chargedCentavos) {
        throw ArgumentError('Paid amount cannot be less than charged amount');
      }

      // Fetch old items to capture before_json and respect capital snapshot rules
      final oldItems = await (_db.select(
        _db.saleItems,
      )..where((i) => i.saleId.equals(saleId))).get();

      // Fetch current catalog products to obtain current capital for new/changed products
      final catalogProducts = await _db.select(_db.products).get();
      final productMap = {for (final p in catalogProducts) p.id: p};

      // 1. Calculate before_json state
      final oldLineValues = [
        for (final item in oldItems)
          PricingCalculator.computeLineValue(
            grams: item.grams,
            pricePerKgCentavos: item.pricePerKgCentavos,
          ),
      ];
      final oldDiscount = sale.exactTotalCentavos > sale.chargedCentavos
          ? sale.exactTotalCentavos - sale.chargedCentavos
          : 0;
      final oldDiscounts = PricingCalculator.allocateDiscount(
        lineValuesCentavos: oldLineValues,
        totalDiscountCentavos: oldDiscount,
      );

      final beforeMap = {
        'id': sale.id,
        'created_at': sale.createdAt.toIso8601String(),
        'exact_total_centavos': sale.exactTotalCentavos,
        'charged_centavos': sale.chargedCentavos,
        'paid_centavos': sale.paidCentavos,
        'change_centavos': sale.changeCentavos,
        'voided': sale.voided,
        'lines': [
          for (int i = 0; i < oldItems.length; i++)
            {
              'id': oldItems[i].id,
              'product_id': oldItems[i].productId,
              'product_name': oldItems[i].productNameSnapshot,
              'grams': oldItems[i].grams,
              'price_per_kg_centavos': oldItems[i].pricePerKgCentavos,
              'capital_per_kg_centavos': oldItems[i].capitalPerKgCentavos,
              'line_value_centavos': oldLineValues[i],
              'line_discount_centavos': oldDiscounts[i],
            },
        ],
      };

      // 2. Resolve capital for new lines according to invariants
      final effectiveCapitals = <int>[];
      for (final line in newLines) {
        int capital;
        if (line.originalItemId != null) {
          final matchedOld = oldItems
              .where((i) => i.id == line.originalItemId)
              .firstOrNull;
          if (matchedOld != null && matchedOld.productId == line.productId) {
            // Line unchanged in product: KEEP its original capital_per_kg snapshot
            capital = matchedOld.capitalPerKgCentavos;
          } else {
            // Product changed: use that product's CURRENT capital per kg
            capital =
                productMap[line.productId]?.capitalCentavos ??
                line.capitalPerKgCentavos;
          }
        } else {
          // Check if there is an old item with matching product
          final matchedOld = oldItems
              .where((i) => i.productId == line.productId)
              .firstOrNull;
          if (matchedOld != null) {
            capital = matchedOld.capitalPerKgCentavos;
          } else {
            // Newly added line: use that product's CURRENT capital per kg
            capital =
                productMap[line.productId]?.capitalCentavos ??
                line.capitalPerKgCentavos;
          }
        }
        effectiveCapitals.add(capital);
      }

      // 3. Recompute new exact total, discount allocation, change
      final newLineValues = [
        for (final line in newLines)
          PricingCalculator.computeLineValue(
            grams: line.weight.grams,
            pricePerKgCentavos: line.pricePerKgCentavos,
          ),
      ];
      final exactTotal = newLineValues.fold<int>(0, (sum, v) => sum + v);
      final changeCentavos = paidCentavos - chargedCentavos;
      final totalDiscount = exactTotal > chargedCentavos
          ? exactTotal - chargedCentavos
          : 0;
      final newDiscounts = PricingCalculator.allocateDiscount(
        lineValuesCentavos: newLineValues,
        totalDiscountCentavos: totalDiscount,
      );

      final editedAt = DateTime.now();

      // 4. Update sales header
      await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          exactTotalCentavos: Value(exactTotal),
          chargedCentavos: Value(chargedCentavos),
          paidCentavos: Value(paidCentavos),
          changeCentavos: Value(changeCentavos),
          editedAt: Value(editedAt),
          editCount: Value(sale.editCount + 1),
        ),
      );

      // 5. Replace sale_items
      await (_db.delete(
        _db.saleItems,
      )..where((i) => i.saleId.equals(saleId))).go();

      final insertedItems = <SaleItem>[];
      for (int i = 0; i < newLines.length; i++) {
        final line = newLines[i];
        final item = await _db
            .into(_db.saleItems)
            .insertReturning(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: line.productId,
                productNameSnapshot: line.productName,
                grams: line.weight.grams,
                pricePerKgCentavos: line.pricePerKgCentavos,
                capitalPerKgCentavos: effectiveCapitals[i],
              ),
            );
        insertedItems.add(item);
      }

      // 6. Record after_json and insert into sale_edits audit ledger
      final afterMap = {
        'id': sale.id,
        'created_at': sale.createdAt.toIso8601String(),
        'exact_total_centavos': exactTotal,
        'charged_centavos': chargedCentavos,
        'paid_centavos': paidCentavos,
        'change_centavos': changeCentavos,
        'voided': sale.voided,
        'lines': [
          for (int i = 0; i < insertedItems.length; i++)
            {
              'id': insertedItems[i].id,
              'product_id': insertedItems[i].productId,
              'product_name': insertedItems[i].productNameSnapshot,
              'grams': insertedItems[i].grams,
              'price_per_kg_centavos': insertedItems[i].pricePerKgCentavos,
              'capital_per_kg_centavos': insertedItems[i].capitalPerKgCentavos,
              'line_value_centavos': newLineValues[i],
              'line_discount_centavos': newDiscounts[i],
            },
        ],
      };

      await _db
          .into(_db.saleEdits)
          .insert(
            SaleEditsCompanion.insert(
              saleId: saleId,
              editedAt: editedAt,
              beforeJson: jsonEncode(beforeMap),
              afterJson: jsonEncode(afterMap),
              reason: Value(reason),
            ),
          );

      final updatedSale = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      return CompletedSaleResult(
        sale: updatedSale,
        items: insertedItems,
        discountCentavos: totalDiscount,
      );
    });
  }

  /// Retrieves chronological audit edits for a sale.
  Future<List<SaleEdit>> getSaleEdits(int saleId) {
    return (_db.select(_db.saleEdits)
          ..where((e) => e.saleId.equals(saleId))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.editedAt, mode: OrderingMode.desc),
            (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Streams chronological audit edits for a sale.
  Stream<List<SaleEdit>> watchSaleEdits(int saleId) {
    return (_db.select(_db.saleEdits)
          ..where((e) => e.saleId.equals(saleId))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.editedAt, mode: OrderingMode.desc),
            (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Counts how many non-voided sales on a day have been edited.
  Future<int> getEditedSalesCountForDay(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    final result =
        await (_db.select(_db.sales)..where(
              (s) =>
                  s.createdAt.isBiggerOrEqualValue(start) &
                  s.createdAt.isSmallerOrEqualValue(end) &
                  s.voided.equals(false) &
                  s.editCount.isBiggerThanValue(0),
            ))
            .get();

    return result.length;
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

  /// Retrieves sales with details, optionally filtered by a specific calendar day or date range.
  /// Performs a single batched query for line items to eliminate N+1 overhead.
  Future<List<SaleWithDetails>> getSalesWithDetails({
    DateTime? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
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
    } else if (startDate != null && endDate != null) {
      final start = _startOfDay(startDate);
      final end = _endOfDay(endDate);
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
    if (sales.isEmpty) return [];

    final saleIds = sales.map((s) => s.id).toList();
    final allItems = await (_db.select(
      _db.saleItems,
    )..where((i) => i.saleId.isIn(saleIds))).get();

    final itemsBySaleId = <int, List<SaleItem>>{};
    for (final item in allItems) {
      itemsBySaleId.putIfAbsent(item.saleId, () => []).add(item);
    }

    return sales
        .map((s) => SaleWithDetails(sale: s, items: itemsBySaleId[s.id] ?? []))
        .toList();
  }

  /// Streams sales with details for real-time reactivity without N+1 queries.
  Stream<List<SaleWithDetails>> watchSalesWithDetails({
    DateTime? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
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
    } else if (startDate != null && endDate != null) {
      final start = _startOfDay(startDate);
      final end = _endOfDay(endDate);
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
      if (sales.isEmpty) return [];
      final saleIds = sales.map((s) => s.id).toList();
      final allItems = await (_db.select(
        _db.saleItems,
      )..where((i) => i.saleId.isIn(saleIds))).get();

      final itemsBySaleId = <int, List<SaleItem>>{};
      for (final item in allItems) {
        itemsBySaleId.putIfAbsent(item.saleId, () => []).add(item);
      }

      return sales
          .map(
            (s) => SaleWithDetails(sale: s, items: itemsBySaleId[s.id] ?? []),
          )
          .toList();
    });
  }
}
