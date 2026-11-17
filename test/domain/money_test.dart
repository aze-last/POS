// ignore_for_file: deprecated_member_use, depend_on_referenced_packages
import 'package:test_api/test_api.dart';
import 'package:matcher/expect.dart';
import 'package:pos/domain/models/money.dart';
import 'package:pos/domain/utils/formatters.dart';

void main() {
  group('Money & Formatters', () {
    test('formats zero centavos', () {
      expect(formatMoney(0), equals('P0.00'));
      expect(Money(0).formatted, equals('P0.00'));
    });

    test('formats centavos under 1 peso', () {
      expect(formatMoney(5), equals('P0.05'));
      expect(formatMoney(50), equals('P0.50'));
    });

    test('formats standard peso amounts', () {
      expect(formatMoney(2500), equals('P25.00'));
      expect(formatMoney(3250), equals('P32.50'));
    });

    test('formats amounts with thousands commas', () {
      expect(formatMoney(123450), equals('P1,234.50'));
      expect(formatMoney(100000000), equals('P1,000,000.00'));
    });

    test('formats negative amounts with leading minus', () {
      expect(formatMoney(-3250), equals('-P32.50'));
      expect(formatMoney(-50), equals('-P0.50'));
      expect(formatMoney(-123456), equals('-P1,234.56'));
    });

    test('rounds whole peso down and up', () {
      // 3250 centavos = P32.50
      expect(roundDownToWholePeso(3250), equals(3200)); // P32.00
      expect(roundUpToWholePeso(3250), equals(3300)); // P33.00

      // Already whole peso: 2500 centavos = P25.00
      expect(roundDownToWholePeso(2500), equals(2500));
      expect(roundUpToWholePeso(2500), equals(2500));

      // 1 centavo: P0.01
      expect(roundDownToWholePeso(1), equals(0));
      expect(roundUpToWholePeso(1), equals(100));
    });

    test('Money operators behave predictably', () {
      const m1 = Money(2500);
      const m2 = Money(750);
      expect((m1 + m2).centavos, equals(3250));
      expect((m1 - m2).centavos, equals(1750));
      expect(m1 > m2, isTrue);
      expect(m2 < m1, isTrue);
    });

    test('parsePesoStringToCentavos parses exact centavos without float conversion', () {
      expect(parsePesoStringToCentavos('35'), equals(3500));
      expect(parsePesoStringToCentavos('35.50'), equals(3550));
      expect(parsePesoStringToCentavos('35.5'), equals(3550));
      expect(parsePesoStringToCentavos('0.50'), equals(50));
      expect(parsePesoStringToCentavos('.50'), equals(50));
      expect(parsePesoStringToCentavos('1234.56'), equals(123456));
      expect(parsePesoStringToCentavos(''), isNull);
      expect(parsePesoStringToCentavos('abc'), isNull);
      expect(parsePesoStringToCentavos('-5'), isNull);
    });
  });
}
