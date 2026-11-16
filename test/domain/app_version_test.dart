import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/models/app_version.dart';

void main() {
  group('AppVersion Semantic Versioning Tests', () {
    test('parses valid versions with and without leading v', () {
      final v1 = AppVersion.tryParse('v1.0.9');
      expect(v1, isNotNull);
      expect(v1!.major, equals(1));
      expect(v1.minor, equals(0));
      expect(v1.patch, equals(9));

      final v2 = AppVersion.tryParse('2.5.12');
      expect(v2, isNotNull);
      expect(v2!.major, equals(2));
      expect(v2.minor, equals(5));
      expect(v2.patch, equals(12));

      final v3 = AppVersion.tryParse('v1.0.0+3');
      expect(v3, isNotNull);
      expect(v3!.build, equals(3));
    });

    test('ignores malformed version tags', () {
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('invalid'), isNull);
      expect(AppVersion.tryParse('1.0'), isNull);
      expect(AppVersion.tryParse('1.0.0.0'), isNull);
      expect(AppVersion.tryParse('v1.a.3'), isNull);
      expect(AppVersion.tryParse('-1.0.0'), isNull);
    });

    test('correctly orders semantic versions (1.0.9 < 1.0.10)', () {
      final v109 = AppVersion.tryParse('v1.0.9')!;
      final v1010 = AppVersion.tryParse('v1.0.10')!;
      expect(v109 < v1010, isTrue);
      expect(v1010 > v109, isTrue);
    });

    test('correctly orders major and minor versions (1.2.0 > 1.1.99)', () {
      final v1199 = AppVersion.tryParse('v1.1.99')!;
      final v120 = AppVersion.tryParse('v1.2.0')!;
      expect(v120 > v1199, isTrue);
      expect(v1199 < v120, isTrue);

      final v200 = AppVersion.tryParse('v2.0.0')!;
      expect(v200 > v120, isTrue);
    });

    test('evaluates equality and identical versions', () {
      final v1 = AppVersion.tryParse('v1.0.0')!;
      final v2 = AppVersion.tryParse('1.0.0')!;
      expect(v1 == v2, isTrue);
      expect(v1.compareTo(v2), equals(0));
      expect(v1 >= v2, isTrue);
      expect(v1 <= v2, isTrue);
    });

    test('never downgrades when candidate is smaller or equal', () {
      final current = AppVersion.tryParse('1.0.5')!;
      final candidateOld = AppVersion.tryParse('1.0.4')!;
      final candidateSame = AppVersion.tryParse('1.0.5')!;
      final candidateNew = AppVersion.tryParse('1.0.6')!;

      expect(candidateOld > current, isFalse);
      expect(candidateSame > current, isFalse);
      expect(candidateNew > current, isTrue);
    });
  });
}
