import 'package:drift/drift.dart';

import '../../domain/services/pricing_calculator.dart';
import '../database/app_database.dart';
import 'sale_repository.dart';

/// Aggregated breakdown of daily expenses.
class DailyExpenseSummary {
  final int spoilageCentavos;
  final int otherExpensesCentavos;

  const DailyExpenseSummary({
    required this.spoilageCentavos,
    required this.otherExpensesCentavos,
  });

  int get totalExpensesCentavos => spoilageCentavos + otherExpensesCentavos;
}

/// Repository responsible for tracking operational expenses and produce spoilage.
class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  /// Checks if a day's payout is locked.
  Future<bool> isDayLocked(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    final locked =
        await (_db.select(_db.payouts)..where(
              (p) =>
                  p.date.isBiggerOrEqualValue(start) &
                  p.date.isSmallerOrEqualValue(end) &
                  p.locked.equals(true),
            ))
            .get();

    return locked.isNotEmpty;
  }

  /// Adds a general operational expense (transport or other).
  Future<int> addGeneralExpense({
    required DateTime date,
    required String type,
    required int amountCentavos,
    String? note,
  }) async {
    if (type != 'transport' && type != 'other') {
      throw ArgumentError.value(type, 'type', 'Invalid expense type');
    }
    if (amountCentavos <= 0) {
      throw ArgumentError.value(
        amountCentavos,
        'amountCentavos',
        'Amount must be greater than 0',
      );
    }

    if (await isDayLocked(date)) {
      throw const SaleModificationLockedException(
        'Cannot add expenses to a locked day payout.',
      );
    }

    return _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            date: date,
            type: type,
            amountCentavos: amountCentavos,
            note: Value(note),
          ),
        );
  }

  /// Records a produce spoilage expense with snapshotted weight and capital per kg.
  Future<int> addSpoilageExpense({
    required DateTime date,
    required int productId,
    required int grams,
    required int capitalPerKgCentavos,
    String? note,
  }) async {
    if (grams <= 0) {
      throw ArgumentError.value(grams, 'grams', 'Grams must be greater than 0');
    }
    if (capitalPerKgCentavos <= 0) {
      throw ArgumentError.value(
        capitalPerKgCentavos,
        'capitalPerKgCentavos',
        'Capital must be greater than 0',
      );
    }

    if (await isDayLocked(date)) {
      throw const SaleModificationLockedException(
        'Cannot record spoilage on a locked day payout.',
      );
    }

    final computedLossCentavos = PricingCalculator.computeLineCapital(
      grams: grams,
      capitalPerKgCentavos: capitalPerKgCentavos,
    );

    return _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            date: date,
            type: 'spoilage',
            amountCentavos: computedLossCentavos,
            note: Value(note),
            productId: Value(productId),
            grams: Value(grams),
            capitalPerKgCentavos: Value(capitalPerKgCentavos),
          ),
        );
  }

  /// Deletes an expense item by ID with day-lock protection.
  Future<void> deleteExpense(int id) async {
    final expense = await (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id))).getSingleOrNull();

    if (expense == null) return;

    if (await isDayLocked(expense.date)) {
      throw const SaleModificationLockedException(
        'Cannot delete expenses from a locked day payout.',
      );
    }

    await (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
  }

  /// Retrieves all expenses for a specific calendar date.
  Future<List<Expense>> getExpensesForDay(DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    return (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.date.isBiggerOrEqualValue(start) &
                e.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([
            (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Streams expenses for a specific calendar date.
  Stream<List<Expense>> watchExpensesForDay(DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    return (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.date.isBiggerOrEqualValue(start) &
                e.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([
            (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Streams expenses for an arbitrary date range.
  Stream<List<Expense>> watchExpensesForRange(DateTime start, DateTime end) {
    final s = _startOfDay(start);
    final e = _endOfDay(end);

    return (_db.select(_db.expenses)
          ..where(
            (ex) =>
                ex.date.isBiggerOrEqualValue(s) &
                ex.date.isSmallerOrEqualValue(e),
          )
          ..orderBy([
            (ex) => OrderingTerm(expression: ex.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Retrieves expenses for an arbitrary date range.
  Future<List<Expense>> getExpensesForRange(DateTime start, DateTime end) {
    final s = _startOfDay(start);
    final e = _endOfDay(end);

    return (_db.select(_db.expenses)
          ..where(
            (ex) =>
                ex.date.isBiggerOrEqualValue(s) &
                ex.date.isSmallerOrEqualValue(e),
          )
          ..orderBy([
            (ex) => OrderingTerm(expression: ex.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Computes the aggregated breakdown of spoilage vs other expenses for a day.
  Future<DailyExpenseSummary> getDailyExpenseSummary(DateTime date) async {
    final expenses = await getExpensesForDay(date);

    int spoilage = 0;
    int other = 0;

    for (final exp in expenses) {
      if (exp.type == 'spoilage') {
        spoilage += exp.amountCentavos;
      } else {
        other += exp.amountCentavos;
      }
    }

    return DailyExpenseSummary(
      spoilageCentavos: spoilage,
      otherExpensesCentavos: other,
    );
  }

  /// Streams the aggregated breakdown of expenses for a day.
  Stream<DailyExpenseSummary> watchDailyExpenseSummary(DateTime date) {
    return watchExpensesForDay(date).map((expenses) {
      int spoilage = 0;
      int other = 0;

      for (final exp in expenses) {
        if (exp.type == 'spoilage') {
          spoilage += exp.amountCentavos;
        } else {
          other += exp.amountCentavos;
        }
      }

      return DailyExpenseSummary(
        spoilageCentavos: spoilage,
        otherExpensesCentavos: other,
      );
    });
  }
}
