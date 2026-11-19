import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/payout_repository.dart';
import '../../domain/services/payout_calculator.dart';
import 'database_provider.dart';
import 'expense_providers.dart';
import 'sale_providers.dart';

/// Provider for PayoutRepository.
final payoutRepositoryProvider = Provider<PayoutRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PayoutRepository(db);
});

/// Current calendar date selected for Daily Summary.
class SelectedDailySummaryDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedDailySummaryDateProvider =
    NotifierProvider<SelectedDailySummaryDateNotifier, DateTime>(
      SelectedDailySummaryDateNotifier.new,
    );

/// View modes for the Summary screen.
enum SummaryViewMode { daily, weekly }

/// Notifier managing current summary view mode (daily vs weekly).
class SummaryViewModeNotifier extends Notifier<SummaryViewMode> {
  @override
  SummaryViewMode build() => SummaryViewMode.daily;

  void setMode(SummaryViewMode mode) {
    state = mode;
  }
}

/// Provider for current summary view mode (daily vs weekly).
final summaryViewModeProvider =
    NotifierProvider<SummaryViewModeNotifier, SummaryViewMode>(
      SummaryViewModeNotifier.new,
    );

/// Reference date inside the week selected for Weekly Summary.
class SelectedWeeklyDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void previousWeek() {
    state = state.subtract(const Duration(days: 7));
  }

  void nextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void setThisWeek() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}

final selectedWeeklyDateProvider =
    NotifierProvider<SelectedWeeklyDateNotifier, DateTime>(
      SelectedWeeklyDateNotifier.new,
    );

/// Stream of system settings.
final settingsStreamProvider = StreamProvider.autoDispose<Setting>((ref) {
  final repo = ref.watch(payoutRepositoryProvider);
  return repo.watchSettings();
});

/// Stream of payout record for a specific day.
final payoutForDayProvider = StreamProvider.autoDispose
    .family<Payout?, DateTime>((ref, date) {
      final repo = ref.watch(payoutRepositoryProvider);
      return repo.watchPayoutForDay(date);
    });

/// Complete daily financial summary state for a selected calendar date.
class DailySummaryState {
  final DateTime date;
  final int salesCount;
  final int editedSalesCount;
  final int totalChargedCentavos;
  final int capitalSoldCentavos;
  final int grossProfitCentavos;
  final int totalDiscountsCentavos;
  final Map<String, int> productGramsSold;
  final int spoilageCentavos;
  final int otherExpensesCentavos;
  final DailyPayoutCalculation calculation;
  final Payout? payout;
  final bool isLocked;
  final Setting settings;

  const DailySummaryState({
    required this.date,
    required this.salesCount,
    required this.editedSalesCount,
    required this.totalChargedCentavos,
    required this.capitalSoldCentavos,
    required this.grossProfitCentavos,
    required this.totalDiscountsCentavos,
    required this.productGramsSold,
    required this.spoilageCentavos,
    required this.otherExpensesCentavos,
    required this.calculation,
    required this.payout,
    required this.isLocked,
    required this.settings,
  });

  /// True if this day was previously marked as paid out, then reopened, and has edited sales.
  bool get showReopenedEditBanner =>
      payout != null && !isLocked && editedSalesCount > 0;
}

/// Comprehensive daily summary provider for a specific calendar date.
/// Automatically reacts to changes in sales, expenses, payouts, or settings.
final dailySummaryStateProvider = StreamProvider.autoDispose
    .family<DailySummaryState, DateTime>((ref, date) {
      final saleRepo = ref.watch(saleRepositoryProvider);

      // React to changes in payout, expenses, and settings
      final payoutAsync = ref.watch(payoutForDayProvider(date));
      final expenseSummaryAsync = ref.watch(expenseSummaryForDayProvider(date));
      final settingsAsync = ref.watch(settingsStreamProvider);

      return saleRepo.watchSalesWithDetails(dateFilter: date).map((
        salesWithDetails,
      ) {
        // Exclude voided sales from all daily totals
        final activeSales = salesWithDetails
            .where((s) => !s.sale.voided)
            .toList();

        final totalCharged = activeSales.fold<int>(
          0,
          (sum, s) => sum + s.sale.chargedCentavos,
        );
        final capitalSold = activeSales.fold<int>(
          0,
          (sum, s) => sum + s.totalCapitalCentavos,
        );
        final totalDiscounts = activeSales.fold<int>(
          0,
          (sum, s) => sum + s.discountCentavos,
        );

        // Product weights sold
        final productGrams = <String, int>{};
        for (final sale in activeSales) {
          for (final item in sale.items) {
            productGrams.update(
              item.productNameSnapshot,
              (prev) => prev + item.grams,
              ifAbsent: () => item.grams,
            );
          }
        }

        final expenseSummary =
            expenseSummaryAsync.value ??
            const DailyExpenseSummary(
              spoilageCentavos: 0,
              otherExpensesCentavos: 0,
            );
        final payout = payoutAsync.value;
        final settings =
            settingsAsync.value ??
            const Setting(
              id: 1,
              salaryMode: 'percent',
              salaryPercentBasisPoints: 3000,
              fixedDailySalaryCentavos: 0,
            );

        final isLocked = payout?.locked ?? false;

        // Determine actual or suggested amounts
        final actualToParents = payout != null && isLocked
            ? payout.toParentsCentavos
            : null;
        final actualSalary = payout != null && isLocked
            ? payout.salaryCentavos
            : null;

        final calculation = PayoutCalculator.calculate(
          salesCentavos: totalCharged,
          capitalSoldCentavos: capitalSold,
          spoilageCentavos: expenseSummary.spoilageCentavos,
          otherExpensesCentavos: expenseSummary.otherExpensesCentavos,
          salaryMode: SalaryMode.fromString(settings.salaryMode),
          salaryPercentBasisPoints: settings.salaryPercentBasisPoints,
          fixedDailySalaryCentavos: settings.fixedDailySalaryCentavos,
          actualToParentsCentavos: actualToParents,
          actualSalaryCentavos: actualSalary,
        );

        final editedCount = activeSales
            .where((s) => s.sale.editCount > 0)
            .length;

        return DailySummaryState(
          date: date,
          salesCount: activeSales.length,
          editedSalesCount: editedCount,
          totalChargedCentavos: totalCharged,
          capitalSoldCentavos: capitalSold,
          grossProfitCentavos: totalCharged - capitalSold,
          totalDiscountsCentavos: totalDiscounts,
          productGramsSold: productGrams,
          spoilageCentavos: expenseSummary.spoilageCentavos,
          otherExpensesCentavos: expenseSummary.otherExpensesCentavos,
          calculation: calculation,
          payout: payout,
          isLocked: isLocked,
          settings: settings,
        );
      });
    });

/// Key class for date range family providers.
class DateRangeKey {
  final DateTime start;
  final DateTime end;

  const DateRangeKey(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeKey &&
          other.start.year == start.year &&
          other.start.month == start.month &&
          other.start.day == start.day &&
          other.end.year == end.year &&
          other.end.month == end.month &&
          other.end.day == end.day;

  @override
  int get hashCode => Object.hash(
    start.year,
    start.month,
    start.day,
    end.year,
    end.month,
    end.day,
  );
}

/// Stream of payouts within a date range.
final payoutsForRangeProvider = StreamProvider.autoDispose
    .family<List<Payout>, DateRangeKey>((ref, range) {
      final repo = ref.watch(payoutRepositoryProvider);
      return repo.watchPayoutsForRange(range.start, range.end);
    });

/// Stream of expenses within a date range.
final expensesForRangeProvider = StreamProvider.autoDispose
    .family<List<Expense>, DateRangeKey>((ref, range) {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.watchExpensesForRange(range.start, range.end);
    });

/// Complete weekly financial summary state for a selected calendar week.
class WeeklySummaryState {
  final DateTime startOfWeek;
  final DateTime endOfWeek;
  final WeeklyPayoutCalculation calculation;
  final Setting settings;

  const WeeklySummaryState({
    required this.startOfWeek,
    required this.endOfWeek,
    required this.calculation,
    required this.settings,
  });
}

/// Comprehensive weekly summary provider for a 7-day Monday–Sunday week.
final weeklySummaryStateProvider = StreamProvider.autoDispose
    .family<WeeklySummaryState, DateTime>((ref, referenceDate) {
      final monday = PayoutCalculator.getMondayOfWeek(referenceDate);
      final sunday = PayoutCalculator.getSundayOfWeek(referenceDate);
      final rangeKey = DateRangeKey(monday, sunday);

      final saleRepo = ref.watch(saleRepositoryProvider);
      final payoutsAsync = ref.watch(payoutsForRangeProvider(rangeKey));
      final expensesAsync = ref.watch(expensesForRangeProvider(rangeKey));
      final settingsAsync = ref.watch(settingsStreamProvider);

      return saleRepo
          .watchSalesWithDetails(startDate: monday, endDate: sunday)
          .map((salesWithDetails) {
            final payouts = payoutsAsync.value ?? [];
            final expenses = expensesAsync.value ?? [];
            final settings =
                settingsAsync.value ??
                const Setting(
                  id: 1,
                  salaryMode: 'percent',
                  salaryPercentBasisPoints: 3000,
                  fixedDailySalaryCentavos: 0,
                );

            final activeSales = salesWithDetails
                .where((s) => !s.sale.voided)
                .toList();

            final days = <WeeklyDaySummary>[];

            for (int i = 0; i < 7; i++) {
              final dayDate = DateTime(
                monday.year,
                monday.month,
                monday.day + i,
              );

              bool isSameDay(DateTime a, DateTime b) =>
                  a.year == b.year && a.month == b.month && a.day == b.day;

              final daySales = activeSales
                  .where((s) => isSameDay(s.sale.createdAt, dayDate))
                  .toList();

              final dayExpenses = expenses
                  .where((e) => isSameDay(e.date, dayDate))
                  .toList();

              final dayCharged = daySales.fold<int>(
                0,
                (sum, s) => sum + s.sale.chargedCentavos,
              );
              final dayCapitalSold = daySales.fold<int>(
                0,
                (sum, s) => sum + s.totalCapitalCentavos,
              );
              final dayGrossProfit = dayCharged - dayCapitalSold;

              int daySpoilage = 0;
              int dayOtherExpenses = 0;
              for (final exp in dayExpenses) {
                if (exp.type == 'spoilage') {
                  daySpoilage += exp.amountCentavos;
                } else {
                  dayOtherExpenses += exp.amountCentavos;
                }
              }

              final dayNetProfit =
                  dayGrossProfit - daySpoilage - dayOtherExpenses;

              final dayPayout = payouts
                  .where((p) => isSameDay(p.date, dayDate))
                  .firstOrNull;

              int toParents;
              int salary;
              int reserve;
              bool isLocked = false;

              if (dayPayout != null && dayPayout.locked) {
                toParents = dayPayout.toParentsCentavos;
                salary = dayPayout.salaryCentavos;
                reserve = dayPayout.reserveCentavos;
                isLocked = true;
              } else {
                final dayCalc = PayoutCalculator.calculate(
                  salesCentavos: dayCharged,
                  capitalSoldCentavos: dayCapitalSold,
                  spoilageCentavos: daySpoilage,
                  otherExpensesCentavos: dayOtherExpenses,
                  salaryMode: SalaryMode.fromString(settings.salaryMode),
                  salaryPercentBasisPoints: settings.salaryPercentBasisPoints,
                  fixedDailySalaryCentavos: settings.fixedDailySalaryCentavos,
                );
                toParents = dayCalc.suggestedToParentsCentavos;
                salary = dayCalc.suggestedSalaryCentavos;
                reserve = dayCalc.reserveCentavos;
                isLocked = false;
              }

              days.add(
                WeeklyDaySummary(
                  date: dayDate,
                  salesCentavos: dayCharged,
                  capitalSoldCentavos: dayCapitalSold,
                  grossProfitCentavos: dayGrossProfit,
                  spoilageCentavos: daySpoilage,
                  otherExpensesCentavos: dayOtherExpenses,
                  netProfitCentavos: dayNetProfit,
                  toParentsCentavos: toParents,
                  salaryCentavos: salary,
                  reserveCentavos: reserve,
                  isLocked: isLocked,
                ),
              );
            }

            final calculation = PayoutCalculator.calculateWeekly(
              referenceDate: referenceDate,
              days: days,
            );

            return WeeklySummaryState(
              startOfWeek: monday,
              endOfWeek: sunday,
              calculation: calculation,
              settings: settings,
            );
          });
    });
