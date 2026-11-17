import '../models/money.dart';

/// Handles all pricing, rounding, and discount allocations for Banana POS.
///
/// Guaranteed pure Dart and 100% integer arithmetic (zero floating-point).
class PricingCalculator {
  /// Computes line value in centavos using round-half-up integer arithmetic:
  /// round_half_up(price_per_kg_centavos * grams / 1000).
  static int computeLineValue({
    required int grams,
    required int pricePerKgCentavos,
  }) {
    if (grams <= 0) {
      throw ArgumentError.value(grams, 'grams', 'grams must be greater than 0');
    }
    if (pricePerKgCentavos <= 0) {
      throw ArgumentError.value(
        pricePerKgCentavos,
        'pricePerKgCentavos',
        'price per kg must be greater than 0',
      );
    }

    final product = pricePerKgCentavos * grams;
    // Integer round-half-up division by 1000
    return (product + 500) ~/ 1000;
  }

  /// Computes line value wrapped in strongly typed [Money].
  static Money computeLineMoney({
    required int grams,
    required int pricePerKgCentavos,
  }) {
    return Money(
      computeLineValue(grams: grams, pricePerKgCentavos: pricePerKgCentavos),
    );
  }

  /// Computes line capital cost in centavos using the snapshotted capital per kg.
  static int computeLineCapital({
    required int grams,
    required int capitalPerKgCentavos,
  }) {
    return computeLineValue(
      grams: grams,
      pricePerKgCentavos: capitalPerKgCentavos,
    );
  }

  /// Allocates total discount across lines proportional to their line values
  /// using the Largest-Remainder Method (Hare-Niemeyer).
  ///
  /// Guarantees the allocated pieces sum EXACTLY to totalDiscountCentavos
  /// with zero lost centavos.
  static List<int> allocateDiscount({
    required List<int> lineValuesCentavos,
    required int totalDiscountCentavos,
  }) {
    final count = lineValuesCentavos.length;
    if (count == 0 || totalDiscountCentavos <= 0) {
      return List<int>.filled(count, 0);
    }

    final totalValue = lineValuesCentavos.fold<int>(0, (sum, val) => sum + val);
    if (totalValue <= 0) {
      return List<int>.filled(count, 0);
    }

    // Cap total discount at total line value to prevent negative line charges
    final effectiveDiscount = totalDiscountCentavos > totalValue
        ? totalValue
        : totalDiscountCentavos;

    final baseAllocations = List<int>.filled(count, 0);
    final remainders = List<int>.filled(count, 0);
    int sumBase = 0;

    for (int i = 0; i < count; i++) {
      final numerator = effectiveDiscount * lineValuesCentavos[i];
      final base = numerator ~/ totalValue;
      final rem = numerator % totalValue;
      baseAllocations[i] = base;
      remainders[i] = rem;
      sumBase += base;
    }

    final discrepancy = effectiveDiscount - sumBase;

    // Create indexed list to sort by remainder descending
    final indices = List<int>.generate(count, (i) => i);
    indices.sort((a, b) {
      final remCompare = remainders[b].compareTo(remainders[a]);
      if (remCompare != 0) return remCompare;
      // Stable tie-breaking: higher line value, then earlier index
      final valCompare = lineValuesCentavos[b].compareTo(lineValuesCentavos[a]);
      if (valCompare != 0) return valCompare;
      return a.compareTo(b);
    });

    // Distribute 1 extra centavo to the top discrepancy items
    for (int i = 0; i < discrepancy; i++) {
      baseAllocations[indices[i]] += 1;
    }

    return baseAllocations;
  }
}
