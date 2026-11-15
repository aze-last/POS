import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/product_repository.dart';
import 'database_provider.dart';

/// Provider for ProductRepository instance.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductRepository(db);
});

/// Stream provider for real-time active products list.
final activeProductsProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchActiveProducts();
});

/// Stream provider for real-time archived products list.
final archivedProductsProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchArchivedProducts();
});

/// Future provider family for product capital history.
final capitalHistoryProvider =
    FutureProvider.family<List<CapitalHistoryData>, int>((ref, productId) {
      final repo = ref.watch(productRepositoryProvider);
      return repo.getCapitalHistory(productId);
    });
