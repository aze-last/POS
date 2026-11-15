import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/expense_repository.dart';
import 'database_provider.dart';

/// Provider for ExpenseRepository.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepository(db);
});

/// Notifier for currently selected date on expenses screen.
class SelectedExpensesDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedExpensesDateProvider =
    NotifierProvider<SelectedExpensesDateNotifier, DateTime>(
      SelectedExpensesDateNotifier.new,
    );

/// Stream of expenses for a specific date.
final expensesForDayProvider = StreamProvider.autoDispose
    .family<List<Expense>, DateTime>((ref, date) {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.watchExpensesForDay(date);
    });

/// Stream of daily expense totals for a specific date.
final expenseSummaryForDayProvider = StreamProvider.autoDispose
    .family<DailyExpenseSummary, DateTime>((ref, date) {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.watchDailyExpenseSummary(date);
    });
