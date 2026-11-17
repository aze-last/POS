// ignore_for_file: deprecated_member_use, depend_on_referenced_packages
import 'package:test_api/test_api.dart';
import 'package:matcher/expect.dart';
import 'package:pos/domain/services/pricing_calculator.dart';

void main() {
  group('PricingCalculator', () {
    test('1300 g @ P25.00/kg (2500 centavos) = 3250 centavos', () {
      final lineValue = PricingCalculator.computeLineValue(
        grams: 1300,
        pricePerKgCentavos: 2500,
      );
      expect(lineValue, equals(3250));
    });

    test('fractional centavo half-up rounding (1301 g @ P25.99/kg)', () {
      // 1301 * 2599 = 3,381,299 / 1000 = 3381.299 -> rounds down to 3381
      final lineValue = PricingCalculator.computeLineValue(
        grams: 1301,
        pricePerKgCentavos: 2599,
      );
      expect(lineValue, equals(3381));

      // Test exact half-up boundary:
      // Want numerator % 1000 == 500
      // e.g., 2500 * 500 = 1,250,000 / 1000 = 1250 (exact)
      // e.g. 3 * 500 = 1500 / 1000 = 1.5 -> rounds to 2
      expect(
        PricingCalculator.computeLineValue(grams: 500, pricePerKgCentavos: 3),
        equals(2),
      );
      // e.g. 1 * 500 = 500 / 1000 = 0.5 -> rounds to 1
      expect(
        PricingCalculator.computeLineValue(grams: 500, pricePerKgCentavos: 1),
        equals(1),
      );
      // e.g. 1 * 499 = 499 / 1000 = 0.499 -> rounds to 0
      expect(
        PricingCalculator.computeLineValue(grams: 499, pricePerKgCentavos: 1),
        equals(0),
      );

      // Rejects non-positive price
      expect(
        () => PricingCalculator.computeLineValue(
          grams: 1000,
          pricePerKgCentavos: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => PricingCalculator.computeLineValue(
          grams: 1000,
          pricePerKgCentavos: -10,
        ),
        throwsArgumentError,
      );
    });

    test('rejects grams <= 0 or pricePerKg < 0', () {
      expect(
        () => PricingCalculator.computeLineValue(
          grams: 0,
          pricePerKgCentavos: 2500,
        ),
        throwsArgumentError,
      );
      expect(
        () => PricingCalculator.computeLineValue(
          grams: 100,
          pricePerKgCentavos: -1,
        ),
        throwsArgumentError,
      );
    });

    group('Discount Allocation (Largest Remainder Method)', () {
      test('1 line gets exact discount', () {
        final lineValues = [3250];
        const totalDiscount = 50; // exact total 3250, charged 3200
        final allocated = PricingCalculator.allocateDiscount(
          lineValuesCentavos: lineValues,
          totalDiscountCentavos: totalDiscount,
        );

        expect(allocated, equals([50]));
        expect(allocated.reduce((a, b) => a + b), equals(totalDiscount));
      });

      test('2 lines allocate proportionally and sum exactly', () {
        final lineValues = [3250, 1750]; // Total = 5000
        const totalDiscount = 100;
        final allocated = PricingCalculator.allocateDiscount(
          lineValuesCentavos: lineValues,
          totalDiscountCentavos: totalDiscount,
        );

        // 3250/5000 * 100 = 65, 1750/5000 * 100 = 35
        expect(allocated, equals([65, 35]));
        expect(allocated.reduce((a, b) => a + b), equals(totalDiscount));
      });

      test(
        '3 lines with fractional remainders sum exactly to total discount',
        () {
          // Line values: 1000, 1000, 1000 -> Total = 3000
          // Total discount: 10 centavos
          // 10 / 3 = 3 remainder 1. Exactly one line gets 4, others get 3.
          final lineValues = [1000, 1000, 1000];
          const totalDiscount = 10;
          final allocated = PricingCalculator.allocateDiscount(
            lineValuesCentavos: lineValues,
            totalDiscountCentavos: totalDiscount,
          );

          expect(allocated.reduce((a, b) => a + b), equals(totalDiscount));
          expect(allocated.where((d) => d == 4).length, equals(1));
          expect(allocated.where((d) => d == 3).length, equals(2));
        },
      );

      test('7 lines with asymmetric values sum exactly to total discount', () {
        final lineValues = [1234, 5678, 910, 4321, 876, 2345, 6789];
        const totalDiscount = 153; // Charged = 22000

        final allocated = PricingCalculator.allocateDiscount(
          lineValuesCentavos: lineValues,
          totalDiscountCentavos: totalDiscount,
        );

        expect(allocated.length, equals(7));
        expect(allocated.reduce((a, b) => a + b), equals(totalDiscount));
        // Every line discount must be <= line value
        for (int i = 0; i < lineValues.length; i++) {
          expect(allocated[i] >= 0, isTrue);
          expect(allocated[i] <= lineValues[i], isTrue);
        }
      });

      test('zero discount returns list of zeros', () {
        final lineValues = [1000, 2000, 3000];
        final allocated = PricingCalculator.allocateDiscount(
          lineValuesCentavos: lineValues,
          totalDiscountCentavos: 0,
        );
        expect(allocated, equals([0, 0, 0]));
      });
    });
  });
}
