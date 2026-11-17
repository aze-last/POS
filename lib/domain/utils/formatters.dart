/// Single shared currency formatter for Banana POS.
///
/// Formats integer centavos as "P1,234.50" (or "-P1,234.50" if negative).
/// Integer-only math without floating-point conversion.
String formatMoney(int centavos) {
  final isNegative = centavos < 0;
  final absCentavos = centavos.abs();
  final pesos = absCentavos ~/ 100;
  final remainingCentavos = absCentavos % 100;

  // Format pesos with thousands comma separators using pure integer string manipulation
  final pesosStr = pesos.toString();
  final buffer = StringBuffer();
  final length = pesosStr.length;

  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(pesosStr[i]);
  }

  final centavosStr = remainingCentavos.toString().padLeft(2, '0');
  final prefix = isNegative ? '-P' : 'P';
  return '$prefix$buffer.$centavosStr';
}

/// Formats integer grams to standard kg string without floating-point conversion.
/// E.g. 1300 -> "1.300 kg", 50 -> "0.050 kg".
String formatWeight(int grams) {
  final kg = grams ~/ 1000;
  final g = (grams % 1000).abs().toString().padLeft(3, '0');
  final prefix = grams < 0 ? '-' : '';
  return '$prefix$kg.$g kg';
}

/// Formats centavos to plain decimal string without currency symbol (e.g. 3250 -> "32.50").
String formatCentavosToDecimal(int centavos) {
  final isNegative = centavos < 0;
  final absCentavos = centavos.abs();
  final pesos = absCentavos ~/ 100;
  final rem = (absCentavos % 100).toString().padLeft(2, '0');
  return '${isNegative ? '-' : ''}$pesos.$rem';
}

/// Rounds centavos down to the nearest whole peso (e.g. 3250 -> 3200).
int roundDownToWholePeso(int centavos) {
  if (centavos <= 0) return 0;
  return (centavos ~/ 100) * 100;
}

/// Rounds centavos up to the nearest whole peso (e.g. 3250 -> 3300).
int roundUpToWholePeso(int centavos) {
  if (centavos <= 0) return 0;
  return ((centavos + 99) ~/ 100) * 100;
}

/// Parses an input string representing pesos (e.g. "35", "35.50", "35.5", ".75")
/// into integer centavos without floating-point conversion.
///
/// Returns null if the input is empty or invalid.
int? parsePesoStringToCentavos(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final parts = trimmed.split('.');
  if (parts.length > 2) return null;

  int pesos = 0;
  if (parts[0].isNotEmpty) {
    final parsedPesos = int.tryParse(parts[0]);
    if (parsedPesos == null || parsedPesos < 0) return null;
    pesos = parsedPesos;
  }

  int centavos = 0;
  if (parts.length == 2) {
    final frac = parts[1];
    if (frac.isEmpty) {
      centavos = 0;
    } else if (frac.length == 1) {
      final parsed = int.tryParse(frac);
      if (parsed == null || parsed < 0) return null;
      centavos = parsed * 10;
    } else if (frac.length == 2) {
      final parsed = int.tryParse(frac);
      if (parsed == null || parsed < 0) return null;
      centavos = parsed;
    } else {
      // More than 2 decimal places: round half-up the third digit
      final firstTwo = int.tryParse(frac.substring(0, 2));
      final third = int.tryParse(frac[2]);
      if (firstTwo == null || third == null) return null;
      centavos = third >= 5 ? firstTwo + 1 : firstTwo;
    }
  }

  return pesos * 100 + centavos;
}
