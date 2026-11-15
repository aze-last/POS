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
  });
}
