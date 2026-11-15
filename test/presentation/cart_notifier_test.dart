import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/models/weight.dart';
import 'package:pos/presentation/providers/cart_provider.dart';

void main() {
  group('CartState & CartNotifier', () {
    test('calculates exact total from lines', () {
      final line1 = CartLine(
        id: '1',
        productId: 1,
        productName: 'Cardava',
        weight: Weight.fromGrams(1300),
        pricePerKgCentavos: 2500, // 3250 centavos
        capitalPerKgCentavos: 2000,
      );

      final line2 = CartLine(
        id: '2',
        productId: 2,
        productName: 'Binanggay',
        weight: Weight.fromGrams(1000),
        pricePerKgCentavos: 3500, // 3500 centavos
        capitalPerKgCentavos: 2500,
      );

      final state = CartState(lines: [line1, line2]);
      expect(state.totalItemCount, equals(2));
      expect(state.exactTotalCentavos, equals(6750));
      expect(state.chargedCentavos, equals(6750));
      expect(state.discountCentavos, equals(0));
    });

    test(
      'round down and round up adjust charged amount and compute discount',
      () {
        final line = CartLine(
          id: '1',
          productId: 1,
          productName: 'Cardava',
          weight: Weight.fromGrams(1300),
          pricePerKgCentavos: 2500, // 3250 centavos = P32.50
          capitalPerKgCentavos: 2000,
        );

        var state = CartState(lines: [line]);
        expect(state.exactTotalCentavos, equals(3250));
        expect(state.chargedCentavos, equals(3250));

        // User taps Round Down -> 3200 (P32.00)
        state = state.copyWith(manualChargedCentavos: () => 3200);
        expect(state.chargedCentavos, equals(3200));
        expect(state.discountCentavos, equals(50)); // P0.50 discount

        // User taps Round Up -> 3300 (P33.00)
        state = state.copyWith(manualChargedCentavos: () => 3300);
        expect(state.chargedCentavos, equals(3300));
        expect(
          state.discountCentavos,
          equals(0),
        ); // No discount when charged >= exact
      },
    );

    test('change calculation and completion eligibility', () {
      final line = CartLine(
        id: '1',
        productId: 1,
        productName: 'Cardava',
        weight: Weight.fromGrams(1000),
        pricePerKgCentavos: 3000,
        capitalPerKgCentavos: 2000,
      );

      var state = CartState(lines: [line], paidCentavos: 2000);
      expect(state.exactTotalCentavos, equals(3000));
      expect(state.paidCentavos, equals(2000));
      expect(state.isPaidSufficient, isFalse);
      expect(state.canComplete, isFalse);

      // User enters exact P30.00
      state = state.copyWith(paidCentavos: 3000);
      expect(state.isPaidSufficient, isTrue);
      expect(state.changeCentavos, equals(0));
      expect(state.canComplete, isTrue);

      // User enters P50.00
      state = state.copyWith(paidCentavos: 5000);
      expect(state.changeCentavos, equals(2000)); // P20.00 change
      expect(state.canComplete, isTrue);
    });

    test('empty cart cannot be completed', () {
      const state = CartState(lines: [], paidCentavos: 5000);
      expect(state.canComplete, isFalse);
    });

    test(
      'serializes and deserializes CartLine for local draft persistence',
      () {
        final line = CartLine(
          id: 'test-123',
          productId: 1,
          productName: 'Cardava',
          weight: Weight.fromGrams(1300),
          pricePerKgCentavos: 2500,
          capitalPerKgCentavos: 2000,
        );

        final json = line.toJson();
        final restored = CartLine.fromJson(json);

        expect(restored.id, equals(line.id));
        expect(restored.productId, equals(line.productId));
        expect(restored.productName, equals(line.productName));
        expect(restored.weight.grams, equals(line.weight.grams));
        expect(restored.pricePerKgCentavos, equals(line.pricePerKgCentavos));
        expect(
          restored.capitalPerKgCentavos,
          equals(line.capitalPerKgCentavos),
        );
      },
    );
  });
}
