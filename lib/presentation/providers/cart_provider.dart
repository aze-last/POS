import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/cart_draft_service.dart';
import '../../domain/models/weight.dart';
import '../../domain/services/pricing_calculator.dart';
import '../../domain/utils/formatters.dart';

/// Single item line in the cart.
class CartLine {
  final String id;
  final int productId;
  final String productName;
  final Weight weight;
  final int pricePerKgCentavos;
  final int capitalPerKgCentavos;

  const CartLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.weight,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
  });

  int get lineValueCentavos => PricingCalculator.computeLineValue(
    grams: weight.grams,
    pricePerKgCentavos: pricePerKgCentavos,
  );

  int get lineCapitalCentavos => PricingCalculator.computeLineCapital(
    grams: weight.grams,
    capitalPerKgCentavos: capitalPerKgCentavos,
  );

  CartLine copyWith({Weight? weight, int? pricePerKgCentavos}) {
    return CartLine(
      id: id,
      productId: productId,
      productName: productName,
      weight: weight ?? this.weight,
      pricePerKgCentavos: pricePerKgCentavos ?? this.pricePerKgCentavos,
      capitalPerKgCentavos: capitalPerKgCentavos,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'grams': weight.grams,
    'pricePerKgCentavos': pricePerKgCentavos,
    'capitalPerKgCentavos': capitalPerKgCentavos,
  };

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    id: json['id'] as String,
    productId: json['productId'] as int,
    productName: json['productName'] as String,
    weight: Weight.fromGrams(json['grams'] as int),
    pricePerKgCentavos: json['pricePerKgCentavos'] as int,
    capitalPerKgCentavos: json['capitalPerKgCentavos'] as int,
  );
}

/// State of the active POS cart and checkout calculation.
class CartState {
  final List<CartLine> lines;
  final int? manualChargedCentavos;
  final int paidCentavos;

  const CartState({
    this.lines = const [],
    this.manualChargedCentavos,
    this.paidCentavos = 0,
  });

  int get totalItemCount => lines.length;

  int get exactTotalCentavos =>
      lines.fold<int>(0, (sum, line) => sum + line.lineValueCentavos);

  int get chargedCentavos => manualChargedCentavos ?? exactTotalCentavos;

  int get discountCentavos => exactTotalCentavos > chargedCentavos
      ? exactTotalCentavos - chargedCentavos
      : 0;

  /// Allocates total discount across lines proportional to their line values
  /// using the largest-remainder method (Hare-Niemeyer).
  List<int> get lineDiscountsCentavos {
    if (discountCentavos <= 0 || lines.isEmpty) {
      return List<int>.filled(lines.length, 0);
    }
    return PricingCalculator.allocateDiscount(
      lineValuesCentavos: lines.map((l) => l.lineValueCentavos).toList(),
      totalDiscountCentavos: discountCentavos,
    );
  }

  int get changeCentavos =>
      paidCentavos >= chargedCentavos ? paidCentavos - chargedCentavos : 0;

  bool get isPaidSufficient => paidCentavos >= chargedCentavos;

  bool get canComplete =>
      lines.isNotEmpty && chargedCentavos > 0 && isPaidSufficient;

  CartState copyWith({
    List<CartLine>? lines,
    int? Function()? manualChargedCentavos,
    int? paidCentavos,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      manualChargedCentavos: manualChargedCentavos != null
          ? manualChargedCentavos()
          : this.manualChargedCentavos,
      paidCentavos: paidCentavos ?? this.paidCentavos,
    );
  }
}

final cartDraftServiceProvider = Provider<CartDraftService>(
  (ref) => CartDraftService(),
);

/// Notifier managing active cart state and checkout math.
class CartNotifier extends Notifier<CartState> {
  late final CartDraftService _draftService;
  bool _isDraftLoaded = false;

  @override
  CartState build() {
    _draftService = ref.watch(cartDraftServiceProvider);
    _loadInitialDraft();
    return const CartState();
  }

  Future<void> _loadInitialDraft() async {
    final draftData = await _draftService.loadDraft();
    if (draftData.isNotEmpty) {
      final draftLines = draftData.map(CartLine.fromJson).toList();
      state = state.copyWith(lines: draftLines);
    }
    _isDraftLoaded = true;
  }

  void _persistDraft(List<CartLine> lines) {
    if (!_isDraftLoaded) return;
    _draftService.saveDraft(lines.map((l) => l.toJson()).toList());
  }

  void addLine(CartLine line) {
    final updated = [...state.lines, line];
    state = state.copyWith(lines: updated);
    _persistDraft(updated);
  }

  void updateLine(String id, Weight newWeight, int newPricePerKgCentavos) {
    final updated = state.lines.map((l) {
      if (l.id == id) {
        return l.copyWith(
          weight: newWeight,
          pricePerKgCentavos: newPricePerKgCentavos,
        );
      }
      return l;
    }).toList();

    state = state.copyWith(lines: updated);
    _persistDraft(updated);
  }

  void removeLine(String id) {
    final updated = state.lines.where((l) => l.id != id).toList();
    // Reset manual override on removal to prevent stale charged amount
    state = state.copyWith(lines: updated, manualChargedCentavos: () => null);
    _persistDraft(updated);
  }

  void setChargedAmount(int? centavos) {
    state = state.copyWith(manualChargedCentavos: () => centavos);
  }

  void roundDownCharged() {
    final rounded = roundDownToWholePeso(state.exactTotalCentavos);
    state = state.copyWith(manualChargedCentavos: () => rounded);
  }

  void roundUpCharged() {
    final rounded = roundUpToWholePeso(state.exactTotalCentavos);
    state = state.copyWith(manualChargedCentavos: () => rounded);
  }

  void resetChargedToExact() {
    state = state.copyWith(manualChargedCentavos: () => null);
  }

  void setPaidAmount(int centavos) {
    state = state.copyWith(paidCentavos: centavos);
  }

  void clearCart() {
    state = const CartState();
    _persistDraft([]);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
