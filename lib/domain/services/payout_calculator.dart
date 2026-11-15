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
}
