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
