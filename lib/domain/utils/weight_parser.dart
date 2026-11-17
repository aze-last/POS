/// Pure Dart parser for scale-style single-stream weight input.
///
/// Converts user input string from the on-screen keypad into exact integer grams.
/// Zero float or double arithmetic is used.
///
/// Supported formats:
/// - Decimal stream: e.g. "1.35", "1.350", "0.5", ".75", "2."
///   - Integer part before the dot represents kilograms.
///   - Fractional part after the dot represents up to 3 gram digits.
/// - Integer without dot:
///   - 1 or 2 digits (e.g. "1".."99"): treated as whole kilograms (1 -> 1,000 g, 15 -> 15,000 g).
///   - 3 or 4 digits (e.g. "250", "500", "1350", "2500"): treated as grams (500 -> 500 g, 1350 -> 1,350 g).
///   - 5+ digits: treated as integer grams (e.g. "15000" -> 15,000 g).
/// - Returns 0 for empty, negative, or invalid strings.
int parseWeightStringToGrams(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return 0;

  if (trimmed.contains('.')) {
    final parts = trimmed.split('.');
    if (parts.length > 2) return 0; // Malformed multiple dots

    final kgPart = parts[0].isEmpty ? '0' : parts[0];
    final kg = int.tryParse(kgPart);
    if (kg == null || kg < 0) return 0;

    final fracPart = parts[1];
    // Take at most 3 digits from the fractional part
    final truncatedFrac = fracPart.length > 3
        ? fracPart.substring(0, 3)
        : fracPart;
    final fracPadded = '${truncatedFrac}000'.substring(0, 3);
    final g = int.tryParse(fracPadded);
    if (g == null || g < 0) return 0;

    return kg * 1000 + g;
  }

  // Integer input without a dot
  final value = int.tryParse(trimmed);
  if (value == null || value <= 0) return 0;

  // 1 or 2 digits -> whole kilograms (e.g. 1 -> 1,000g, 15 -> 15,000g)
  if (trimmed.length <= 2) {
    return value * 1000;
  }

  // 3+ digits -> direct grams (e.g. 250 -> 250g, 500 -> 500g, 1350 -> 1350g)
  return value;
}

/// Formats integer grams into human-readable kilograms and grams string.
/// E.g. 1350 -> "1.350 kg (1,350 g)"
String formatGramsWithDetail(int grams) {
  if (grams <= 0) return '0.000 kg (0 g)';
  final kg = grams ~/ 1000;
  final g = (grams % 1000).toString().padLeft(3, '0');
  return '$kg.$g kg ($grams g)';
}
