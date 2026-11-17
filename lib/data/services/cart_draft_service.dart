import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Serializable representation of a cart item in local draft storage.
class DraftCartItem {
  final String id;
  final int productId;
  final String productName;
  final int grams;
  final int pricePerKgCentavos;
  final int capitalPerKgCentavos;

  const DraftCartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.grams,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'grams': grams,
    'pricePerKgCentavos': pricePerKgCentavos,
    'capitalPerKgCentavos': capitalPerKgCentavos,
  };

  factory DraftCartItem.fromJson(Map<String, dynamic> json) => DraftCartItem(
    id: json['id'] as String,
    productId: json['productId'] as int,
    productName: json['productName'] as String,
    grams: json['grams'] as int,
    pricePerKgCentavos: json['pricePerKgCentavos'] as int,
    capitalPerKgCentavos: json['capitalPerKgCentavos'] as int,
  );
}

/// Offline data-layer service managing POS cart draft persistence.
class CartDraftService {
  Future<File?> _getFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(p.join(dir.path, 'draft_cart.json'));
    } catch (_) {
      return null;
    }
  }

  /// Serializes and saves current cart lines to disk.
  Future<void> saveDraft(List<Map<String, dynamic>> items) async {
    try {
      final file = await _getFile();
      if (file == null) return;
      if (items.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }
      await file.writeAsString(jsonEncode(items));
    } catch (_) {}
  }

  /// Loads persisted draft cart items from disk.
  Future<List<Map<String, dynamic>>> loadDraft() async {
    try {
      final file = await _getFile();
      if (file == null || !await file.exists()) return [];
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
