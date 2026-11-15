import '../utils/formatters.dart';

/// Represents exact monetary value in integer centavos.
///
/// Eliminates floating-point rounding errors across the entire codebase.
class Money implements Comparable<Money> {
  final int centavos;

  const Money(this.centavos);

  static const Money zero = Money(0);

  String get formatted => formatMoney(centavos);

  Money operator +(Money other) => Money(centavos + other.centavos);
  Money operator -(Money other) => Money(centavos - other.centavos);

  bool operator >(Money other) => centavos > other.centavos;
  bool operator <(Money other) => centavos < other.centavos;
  bool operator >=(Money other) => centavos >= other.centavos;
  bool operator <=(Money other) => centavos <= other.centavos;

  @override
  int compareTo(Money other) => centavos.compareTo(other.centavos);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          centavos == other.centavos;

  @override
  int get hashCode => centavos.hashCode;

  @override
  String toString() => formatted;
}
