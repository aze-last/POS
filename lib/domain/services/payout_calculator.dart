/// Operating modes for owner daily salary calculation.
enum SalaryMode {
  percent,
  fixed;

  static SalaryMode fromString(String val) {
    if (val.toLowerCase() == 'fixed') return SalaryMode.fixed;
    return SalaryMode.percent;
  }
}

/// Result of complete daily financial payout calculation.
///
/// Implements all 8 formula steps specified in spec.md Section 6.
/// All monetary values are integer centavos.
class DailyPayoutCalculation {
  final int salesCentavos;
  final int capitalSoldCentavos;
  final int grossProfitCentavos;
  final int spoilageCentavos;
  final int otherExpensesCentavos;
  final int netProfitCentavos;
  final int suggestedToParentsCentavos;
  final int suggestedSalaryCentavos;
  final int actualToParentsCentavos;
  final int actualSalaryCentavos;
  final int reserveCentavos;
  final bool isSalaryCapped;

  const DailyPayoutCalculation({
    required this.salesCentavos,
    required this.capitalSoldCentavos,
    required this.grossProfitCentavos,
    required this.spoilageCentavos,
    required this.otherExpensesCentavos,
    required this.netProfitCentavos,
    required this.suggestedToParentsCentavos,
    required this.suggestedSalaryCentavos,
    required this.actualToParentsCentavos,
    required this.actualSalaryCentavos,
    required this.reserveCentavos,
    required this.isSalaryCapped,
  });

  /// True if reserve is negative (Loss / Shortfall day).
  bool get hasShortfall => reserveCentavos < 0;

  /// Difference between actual and suggested payment to parents.
  int get toParentsDiffCentavos =>
      actualToParentsCentavos - suggestedToParentsCentavos;

  /// Difference between actual and suggested salary.
  int get salaryDiffCentavos => actualSalaryCentavos - suggestedSalaryCentavos;
}

/// Service that executes the authoritative daily settlement and payout math.
class PayoutCalculator {
  /// Pure integer calculation of all 8 daily payout formula steps.
  static DailyPayoutCalculation calculate({
    required int salesCentavos,
    required int capitalSoldCentavos,
    required int spoilageCentavos,
    required int otherExpensesCentavos,
    required SalaryMode salaryMode,
    required int salaryPercentBasisPoints,
    required int fixedDailySalaryCentavos,
    int? actualToParentsCentavos,
    int? actualSalaryCentavos,
  }) {
    // 1. sales = sum(charged_centavos)
    // 2. capital_sold = sum(line capital cost)
    // 3. gross_profit = sales - capital_sold
    final grossProfit = salesCentavos - capitalSoldCentavos;

    // 4. spoilage = sum(expenses where type = spoilage)
    //    other_expenses = sum(expenses where type != spoilage)

    // 5. net_profit = gross_profit - spoilage - other_expenses (may be negative)
    final netProfit = grossProfit - spoilageCentavos - otherExpensesCentavos;

    // 6. to_parents = capital_sold + spoilage (suggested)
    final suggestedToParents = capitalSoldCentavos + spoilageCentavos;

    // 7. salary:
    //    percent mode: max(0, net_profit) * salary_percent
    //    fixed mode: min(fixed_daily_salary, max(0, net_profit)); warn if capped
    int suggestedSalary = 0;
    bool isSalaryCapped = false;
    final nonNegativeProfit = netProfit > 0 ? netProfit : 0;

    if (salaryMode == SalaryMode.percent) {
      if (nonNegativeProfit > 0 && salaryPercentBasisPoints > 0) {
        // Integer round_half_up with basis points (100% = 10,000 bps)
        suggestedSalary =
            ((nonNegativeProfit * salaryPercentBasisPoints) + 5000) ~/ 10000;
      }
    } else {
      if (fixedDailySalaryCentavos > 0) {
        if (nonNegativeProfit < fixedDailySalaryCentavos) {
          suggestedSalary = nonNegativeProfit;
          isSalaryCapped = true;
        } else {
          suggestedSalary = fixedDailySalaryCentavos;
        }
      }
    }

    final finalToParents = actualToParentsCentavos ?? suggestedToParents;
    final finalSalary = actualSalaryCentavos ?? suggestedSalary;

    // 8. reserve = sales - to_parents - salary - other_expenses
    final reserve =
        salesCentavos - finalToParents - finalSalary - otherExpensesCentavos;

    return DailyPayoutCalculation(
      salesCentavos: salesCentavos,
      capitalSoldCentavos: capitalSoldCentavos,
      grossProfitCentavos: grossProfit,
      spoilageCentavos: spoilageCentavos,
      otherExpensesCentavos: otherExpensesCentavos,
      netProfitCentavos: netProfit,
      suggestedToParentsCentavos: suggestedToParents,
      suggestedSalaryCentavos: suggestedSalary,
      actualToParentsCentavos: finalToParents,
      actualSalaryCentavos: finalSalary,
      reserveCentavos: reserve,
      isSalaryCapped: isSalaryCapped,
    );
  }

  /// Calculates the Monday (start of week at 00:00:00) for a given date.
  static DateTime getMondayOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Calculates the Sunday (end of week at 23:59:59.999) for a given date.
  static DateTime getSundayOfWeek(DateTime date) {
    final monday = getMondayOfWeek(date);
    return DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59, 999);
  }

  /// Aggregates 7 daily summaries into a complete weekly payout calculation.
  ///
  /// All values are integer centavos only.
  static WeeklyPayoutCalculation calculateWeekly({
    required DateTime referenceDate,
    required List<WeeklyDaySummary> days,
  }) {
    final startOfWeek = getMondayOfWeek(referenceDate);
    final endOfWeek = getSundayOfWeek(referenceDate);

    int totalSales = 0;
    int totalCapitalSold = 0;
    int totalGrossProfit = 0;
    int totalSpoilage = 0;
    int totalOtherExpenses = 0;
    int totalNetProfit = 0;
    int totalToParents = 0;
    int totalSalary = 0;
    int totalReserve = 0;
    int lockedDaysCount = 0;

    for (final day in days) {
      totalSales += day.salesCentavos;
      totalCapitalSold += day.capitalSoldCentavos;
      totalGrossProfit += day.grossProfitCentavos;
      totalSpoilage += day.spoilageCentavos;
      totalOtherExpenses += day.otherExpensesCentavos;
      totalNetProfit += day.netProfitCentavos;
      totalToParents += day.toParentsCentavos;
      totalSalary += day.salaryCentavos;
      totalReserve += day.reserveCentavos;
      if (day.isLocked) lockedDaysCount++;
    }

    return WeeklyPayoutCalculation(
      startOfWeek: startOfWeek,
      endOfWeek: endOfWeek,
      days: days,
      totalSalesCentavos: totalSales,
      totalCapitalSoldCentavos: totalCapitalSold,
      totalGrossProfitCentavos: totalGrossProfit,
      totalSpoilageCentavos: totalSpoilage,
      totalOtherExpensesCentavos: totalOtherExpenses,
      totalNetProfitCentavos: totalNetProfit,
      totalToParentsCentavos: totalToParents,
      totalSalaryCentavos: totalSalary,
      totalReserveCentavos: totalReserve,
      lockedDaysCount: lockedDaysCount,
    );
  }
}

/// Daily summary item inside a weekly payout calculation.
class WeeklyDaySummary {
  final DateTime date;
  final int salesCentavos;
  final int capitalSoldCentavos;
  final int grossProfitCentavos;
  final int spoilageCentavos;
  final int otherExpensesCentavos;
  final int netProfitCentavos;
  final int toParentsCentavos;
  final int salaryCentavos;
  final int reserveCentavos;
  final bool isLocked;

  const WeeklyDaySummary({
    required this.date,
    required this.salesCentavos,
    required this.capitalSoldCentavos,
    required this.grossProfitCentavos,
    required this.spoilageCentavos,
    required this.otherExpensesCentavos,
    required this.netProfitCentavos,
    required this.toParentsCentavos,
    required this.salaryCentavos,
    required this.reserveCentavos,
    required this.isLocked,
  });
}

/// Aggregated financial metrics for an entire 7-day Monday–Sunday week.
class WeeklyPayoutCalculation {
  final DateTime startOfWeek;
  final DateTime endOfWeek;
  final List<WeeklyDaySummary> days;
  final int totalSalesCentavos;
  final int totalCapitalSoldCentavos;
  final int totalGrossProfitCentavos;
  final int totalSpoilageCentavos;
  final int totalOtherExpensesCentavos;
  final int totalNetProfitCentavos;
  final int totalToParentsCentavos;
  final int totalSalaryCentavos;
  final int totalReserveCentavos;
  final int lockedDaysCount;

  const WeeklyPayoutCalculation({
    required this.startOfWeek,
    required this.endOfWeek,
    required this.days,
    required this.totalSalesCentavos,
    required this.totalCapitalSoldCentavos,
    required this.totalGrossProfitCentavos,
    required this.totalSpoilageCentavos,
    required this.totalOtherExpensesCentavos,
    required this.totalNetProfitCentavos,
    required this.totalToParentsCentavos,
    required this.totalSalaryCentavos,
    required this.totalReserveCentavos,
    required this.lockedDaysCount,
  });

  /// True if weekly net reserve is negative (Loss / Shortfall across the week).
  bool get hasShortfall => totalReserveCentavos < 0;
}
