/// Represents an exact weight in integer grams.
///
/// Weight inputs are entered as two fields: kg and g.
/// Valid g: 0–999.
/// Total grams = kg * 1000 + g.
/// 0 total grams is rejected.
class Weight {
  final int grams;

  const Weight._(this.grams);

  factory Weight.fromGrams(int grams) {
    if (grams <= 0) {
      throw ArgumentError.value(
        grams,
        'grams',
        'Total weight in grams must be greater than 0',
      );
    }
    return Weight._(grams);
  }

  factory Weight.fromKgAndG(int kg, int g) {
    if (kg < 0) {
      throw ArgumentError.value(kg, 'kg', 'kg cannot be negative');
    }
    if (g < 0 || g > 999) {
      throw ArgumentError.value(g, 'g', 'g must be between 0 and 999');
    }
    final totalGrams = kg * 1000 + g;
    if (totalGrams <= 0) {
      throw ArgumentError('Total weight must be greater than 0');
    }
    return Weight._(totalGrams);
  }

  int get kg => grams ~/ 1000;
  int get g => grams % 1000;

  /// Formats weight as "1.300 kg" with 3 decimal digits for grams.
  String formatKg() {
    final gStr = g.toString().padLeft(3, '0');
    return '$kg.$gStr kg';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weight &&
          runtimeType == other.runtimeType &&
          grams == other.grams;

  @override
  int get hashCode => grams.hashCode;

  @override
  String toString() => formatKg();
}
