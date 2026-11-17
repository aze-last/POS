// ignore_for_file: deprecated_member_use, depend_on_referenced_packages
import 'package:test_api/test_api.dart';
import 'package:matcher/expect.dart';
import 'package:pos/domain/models/weight.dart';

void main() {
  group('Weight', () {
    test('creates valid weight from grams', () {
      final w = Weight.fromGrams(1300);
      expect(w.grams, equals(1300));
      expect(w.kg, equals(1));
      expect(w.g, equals(300));
      expect(w.formatKg(), equals('1.300 kg'));
    });

    test('creates valid weight from kg and g', () {
      final w = Weight.fromKgAndG(2, 50);
      expect(w.grams, equals(2050));
      expect(w.kg, equals(2));
      expect(w.g, equals(50));
      expect(w.formatKg(), equals('2.050 kg'));
    });

    test('validates boundary g=0 and g=999', () {
      final w0 = Weight.fromKgAndG(1, 0);
      expect(w0.grams, equals(1000));
      expect(w0.formatKg(), equals('1.000 kg'));

      final w999 = Weight.fromKgAndG(0, 999);
      expect(w999.grams, equals(999));
      expect(w999.formatKg(), equals('0.999 kg'));
    });

    test('handles large kg values', () {
      final w = Weight.fromKgAndG(150, 250);
      expect(w.grams, equals(150250));
      expect(w.formatKg(), equals('150.250 kg'));
    });

    test('rejects 0 total grams', () {
      expect(() => Weight.fromGrams(0), throwsArgumentError);
      expect(() => Weight.fromKgAndG(0, 0), throwsArgumentError);
    });

    test('rejects negative grams or kg', () {
      expect(() => Weight.fromGrams(-5), throwsArgumentError);
      expect(() => Weight.fromKgAndG(-1, 500), throwsArgumentError);
      expect(() => Weight.fromKgAndG(1, -1), throwsArgumentError);
    });

    test('rejects g >= 1000 in fromKgAndG', () {
      expect(() => Weight.fromKgAndG(1, 1000), throwsArgumentError);
      expect(() => Weight.fromKgAndG(0, 1500), throwsArgumentError);
    });
  });
}
