import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/services/payout_calculator.dart';

void main() {
  group('PayoutCalculator Domain Tests', () {
    test('standard profitable day with percent salary mode (30%)', () {
      // Sales: P5,000.00 (500,000 centavos)
      // Capital sold: P3,000.00 (300,000 centavos)
      // Gross profit: P2,000.00 (200,000 centavos)
      // Spoilage: P200.00 (20,000 centavos)
      // Other expenses: P300.00 (30,000 centavos)
      // Net profit: 200,000 - 20,000 - 30,000 = 150,000 centavos (P1,500.00)
      // Suggested To Parents: 300,000 + 20,000 = 320,000 centavos (P3,200.00)
      // Suggested Salary (30% = 3000 bps): round_half_up(150,000 * 3000 / 10000) = 45,000 centavos (P450.00)
      // Reserve: 500,000 - 320,000 - 45,000 - 30,000 = 105,000 centavos (P1,050.00)

      final calculation = PayoutCalculator.calculate(
        salesCentavos: 500000,
        capitalSoldCentavos: 300000,
        spoilageCentavos: 20000,
        otherExpensesCentavos: 30000,
        salaryMode: SalaryMode.percent,
        salaryPercentBasisPoints: 3000,
        fixedDailySalaryCentavos: 0,
      );

      expect(calculation.salesCentavos, 500000);
      expect(calculation.capitalSoldCentavos, 300000);
      expect(calculation.grossProfitCentavos, 200000);
      expect(calculation.spoilageCentavos, 20000);
      expect(calculation.otherExpensesCentavos, 30000);
      expect(calculation.netProfitCentavos, 150000);
      expect(calculation.suggestedToParentsCentavos, 320000);
      expect(calculation.suggestedSalaryCentavos, 45000);
      expect(calculation.reserveCentavos, 105000);
      expect(calculation.hasShortfall, isFalse);
      expect(calculation.isSalaryCapped, isFalse);
    });

    test(
      'verifies spoilage is subtracted once inside to_parents, not twice',
      () {
        // Net profit = gross_profit - spoilage - other_expenses
        // Reserve = sales - (capital_sold + spoilage) - salary - other_expenses
        // Notice reserve = net_profit - salary.
        // If spoilage was erroneously subtracted twice from reserve, reserve would be net_profit - salary - spoilage.
        final calculation = PayoutCalculator.calculate(
          salesCentavos: 100000,
          capitalSoldCentavos: 60000,
          spoilageCentavos: 10000,
          otherExpensesCentavos: 5000,
          salaryMode: SalaryMode.percent,
          salaryPercentBasisPoints: 3000,
          fixedDailySalaryCentavos: 0,
        );

        // Gross profit = 40,000
        // Net profit = 40,000 - 10,000 - 5,000 = 25,000
        // Salary = round_half_up(25000 * 3000 / 10000) = 7500
        // To parents = 60000 + 10000 = 70000
        // Reserve = 100000 - 70000 - 7500 - 5000 = 17500
        // Exact check: net_profit (25000) - salary (7500) = 17500!
        expect(calculation.netProfitCentavos, 25000);
        expect(calculation.suggestedSalaryCentavos, 7500);
        expect(calculation.reserveCentavos, 17500);
        expect(
          calculation.reserveCentavos,
          calculation.netProfitCentavos - calculation.suggestedSalaryCentavos,
        );
      },
    );

    test(
      'fixed salary mode with capping warning when net profit < fixed salary',
      () {
        // Fixed salary: P500.00 (50,000 centavos)
        // Net profit: P300.00 (30,000 centavos)
        // Salary must cap at net profit (30,000) and warn
        final calculation = PayoutCalculator.calculate(
          salesCentavos: 100000,
          capitalSoldCentavos: 60000,
          spoilageCentavos: 5000,
          otherExpensesCentavos: 5000,
          salaryMode: SalaryMode.fixed,
          salaryPercentBasisPoints: 3000,
          fixedDailySalaryCentavos: 50000,
        );

        expect(calculation.netProfitCentavos, 30000);
        expect(calculation.suggestedSalaryCentavos, 30000);
        expect(calculation.isSalaryCapped, isTrue);
        expect(calculation.reserveCentavos, 0);
      },
    );

    test('loss day: net profit < 0 results in salary = 0 and reserve shortfall in red', () {
      // Sales: P1,000.00 (100,000 centavos)
      // Capital sold: P800.00 (80,000 centavos)
      // Gross profit: P200.00 (20,000 centavos)
      // Spoilage: P150.00 (15,000 centavos)
      // Other expenses: P200.00 (20,000 centavos)
      // Net profit: 20,000 - 15,000 - 20,000 = -15,000 centavos (-P150.00)
      // Suggested to parents: 80,000 + 15,000 = 95,000 centavos (P950.00)
      // Salary: 0
      // Reserve: 100,000 - 95,000 - 0 - 20,000 = -15,000 centavos (Shortfall!)
      final calculation = PayoutCalculator.calculate(
        salesCentavos: 100000,
        capitalSoldCentavos: 80000,
        spoilageCentavos: 15000,
        otherExpensesCentavos: 20000,
        salaryMode: SalaryMode.percent,
        salaryPercentBasisPoints: 3000,
        fixedDailySalaryCentavos: 0,
      );

      expect(calculation.netProfitCentavos, -15000);
      expect(calculation.suggestedSalaryCentavos, 0);
      expect(calculation.reserveCentavos, -15000);
      expect(calculation.hasShortfall, isTrue);
    });

    test('manual overrides for to_parents and salary compute correct reserve and diffs', () {
      final base = PayoutCalculator.calculate(
        salesCentavos: 200000,
        capitalSoldCentavos: 100000,
        spoilageCentavos: 10000,
        otherExpensesCentavos: 10000,
        salaryMode: SalaryMode.percent,
        salaryPercentBasisPoints: 3000,
        fixedDailySalaryCentavos: 0,
        actualToParentsCentavos:
            120000, // Suggested was 110,000 (+10,000 override)
        actualSalaryCentavos: 30000, // Suggested was 24,000 (+6,000 override)
      );

      expect(base.suggestedToParentsCentavos, 110000);
      expect(base.actualToParentsCentavos, 120000);
      expect(base.toParentsDiffCentavos, 10000);

      expect(base.suggestedSalaryCentavos, 24000);
      expect(base.actualSalaryCentavos, 30000);
      expect(base.salaryDiffCentavos, 6000);

      // Reserve: 200,000 - 120,000 - 30,000 - 10,000 = 40,000
      expect(base.reserveCentavos, 40000);
    });

    test(
      'getMondayOfWeek and getSundayOfWeek properly resolve 7-day bounds',
      () {
        // Wednesday Nov 19, 2026
        final wed = DateTime(2026, 11, 19, 14, 30);
        final mon = PayoutCalculator.getMondayOfWeek(wed);
        final sun = PayoutCalculator.getSundayOfWeek(wed);

        expect(mon.year, 2026);
        expect(mon.month, 11);
        expect(mon.day, 16); // Monday Nov 16
        expect(mon.weekday, DateTime.monday);

        expect(sun.year, 2026);
        expect(sun.month, 11);
        expect(sun.day, 22); // Sunday Nov 22
        expect(sun.weekday, DateTime.sunday);

        // Edge case: Sunday itself
        final sundayDate = DateTime(2026, 11, 22);
        expect(PayoutCalculator.getMondayOfWeek(sundayDate).day, 16);
        expect(PayoutCalculator.getSundayOfWeek(sundayDate).day, 22);

        // Edge case: Month boundary
        final monthBoundary = DateTime(2026, 12, 1); // Tuesday Dec 1
        final monDec = PayoutCalculator.getMondayOfWeek(monthBoundary);
        expect(monDec.month, 11);
        expect(monDec.day, 30); // Monday Nov 30
      },
    );

    test('calculateWeekly aggregates 7 days into exact weekly totals', () {
      final mon = DateTime(2026, 11, 16);
      final days = List.generate(7, (i) {
        final d = DateTime(mon.year, mon.month, mon.day + i);
        // Alternate days: 5 sales days, 2 rest days (0 sales)
        if (i < 5) {
          return WeeklyDaySummary(
            date: d,
            salesCentavos: 100000, // P1,000
            capitalSoldCentavos: 60000, // P600
            grossProfitCentavos: 40000, // P400
            spoilageCentavos: 5000, // P50
            otherExpensesCentavos: 5000, // P50
            netProfitCentavos: 30000, // P300
            toParentsCentavos: 65000, // P650 (600+50)
            salaryCentavos: 9000, // P90 (30% of 300)
            reserveCentavos: 21000, // P210
            isLocked: i < 3, // First 3 days locked
          );
        } else {
          return WeeklyDaySummary(
            date: d,
            salesCentavos: 0,
            capitalSoldCentavos: 0,
            grossProfitCentavos: 0,
            spoilageCentavos: 0,
            otherExpensesCentavos: 0,
            netProfitCentavos: 0,
            toParentsCentavos: 0,
            salaryCentavos: 0,
            reserveCentavos: 0,
            isLocked: false,
          );
        }
      });

      final weekly = PayoutCalculator.calculateWeekly(
        referenceDate: DateTime(2026, 11, 18),
        days: days,
      );

      expect(weekly.totalSalesCentavos, 500000); // 5 * 100,000
      expect(weekly.totalCapitalSoldCentavos, 300000); // 5 * 60,000
      expect(weekly.totalGrossProfitCentavos, 200000); // 5 * 40,000
      expect(weekly.totalSpoilageCentavos, 25000); // 5 * 5,000
      expect(weekly.totalOtherExpensesCentavos, 25000); // 5 * 5,000
      expect(weekly.totalNetProfitCentavos, 150000); // 5 * 30,000
      expect(weekly.totalToParentsCentavos, 325000); // 5 * 65,000
      expect(weekly.totalSalaryCentavos, 45000); // 5 * 9,000
      expect(weekly.totalReserveCentavos, 105000); // 5 * 21,000
      expect(weekly.lockedDaysCount, 3);
      expect(weekly.hasShortfall, isFalse);
    });
  });
}
