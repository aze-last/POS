import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

/// Persistence handler for draft cart across app backgrounding / restarts.
class DraftCartStorage {
  Future<File?> _getFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(p.join(dir.path, 'draft_cart.json'));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(List<CartLine> lines) async {
    try {
      final file = await _getFile();
      if (file == null) return;
      if (lines.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }
      final jsonList = lines.map((l) => l.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<CartLine>> loadDraft() async {
    try {
      final file = await _getFile();
      if (file == null || !await file.exists()) return [];
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((item) => CartLine.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

final draftCartStorageProvider = Provider<DraftCartStorage>(
  (ref) => DraftCartStorage(),
);

/// Notifier managing active cart state and checkout math.
class CartNotifier extends Notifier<CartState> {
  late final DraftCartStorage _storage;

  @override
  CartState build() {
    _storage = ref.watch(draftCartStorageProvider);
    _loadInitialDraft();
    return const CartState();
  }

  Future<void> _loadInitialDraft() async {
    final draftLines = await _storage.loadDraft();
    if (draftLines.isNotEmpty) {
      state = state.copyWith(lines: draftLines);
    }
  }

  void addLine(CartLine line) {
    final updated = [...state.lines, line];
    state = state.copyWith(lines: updated);
    _storage.saveDraft(updated);
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
    _storage.saveDraft(updated);
  }

  void removeLine(String id) {
    final updated = state.lines.where((l) => l.id != id).toList();
    state = state.copyWith(lines: updated);
    _storage.saveDraft(updated);
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
    _storage.saveDraft([]);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
