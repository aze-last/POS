import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/utils/weight_parser.dart';

void main() {
  group('Weight Parser (Scale-Style Single Stream Input)', () {
    test('parses decimal stream with dot correctly', () {
      expect(parseWeightStringToGrams('1.35'), equals(1350));
      expect(parseWeightStringToGrams('1.350'), equals(1350));
      expect(parseWeightStringToGrams('1.3'), equals(1300));
      expect(parseWeightStringToGrams('1.05'), equals(1050));
      expect(parseWeightStringToGrams('1.005'), equals(1005));
      expect(parseWeightStringToGrams('0.5'), equals(500));
      expect(parseWeightStringToGrams('0.05'), equals(50));
      expect(parseWeightStringToGrams('.75'), equals(750));
      expect(parseWeightStringToGrams('2.'), equals(2000));
      expect(
        parseWeightStringToGrams('1.2345'),
        equals(1234),
      ); // Truncated to 3 decimal digits
    });

    test('parses integers without dot (whole kg vs grams)', () {
      // 1 or 2 digits are treated as whole kg
      expect(parseWeightStringToGrams('1'), equals(1000));
      expect(parseWeightStringToGrams('2'), equals(2000));
      expect(parseWeightStringToGrams('5'), equals(5000));
      expect(parseWeightStringToGrams('10'), equals(10000));
      expect(parseWeightStringToGrams('25'), equals(25000));

      // 3 or 4 digits are treated as direct grams
      expect(parseWeightStringToGrams('250'), equals(250));
      expect(parseWeightStringToGrams('500'), equals(500));
      expect(parseWeightStringToGrams('750'), equals(750));
      expect(parseWeightStringToGrams('1350'), equals(1350));
      expect(parseWeightStringToGrams('2000'), equals(2000));
      expect(parseWeightStringToGrams('3500'), equals(3500));

      // 5+ digits
      expect(parseWeightStringToGrams('12000'), equals(12000));
    });

    test('handles invalid, empty, or zero inputs', () {
      expect(parseWeightStringToGrams(''), equals(0));
      expect(parseWeightStringToGrams('   '), equals(0));
      expect(parseWeightStringToGrams('0'), equals(0));
      expect(parseWeightStringToGrams('0.0'), equals(0));
      expect(parseWeightStringToGrams('.'), equals(0));
      expect(parseWeightStringToGrams('-5'), equals(0));
      expect(parseWeightStringToGrams('1.2.3'), equals(0));
      expect(parseWeightStringToGrams('abc'), equals(0));
    });

    test('formatGramsWithDetail formats readable strings', () {
      expect(formatGramsWithDetail(1350), equals('1.350 kg (1350 g)'));
      expect(formatGramsWithDetail(500), equals('0.500 kg (500 g)'));
      expect(formatGramsWithDetail(2000), equals('2.000 kg (2000 g)'));
      expect(formatGramsWithDetail(0), equals('0.000 kg (0 g)'));
    });
  });
}
