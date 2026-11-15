import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/restock_repository.dart';
import 'database_provider.dart';

/// Provider for RestockRepository.
final restockRepositoryProvider = Provider<RestockRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RestockRepository(db);
});

/// Stream of all restock purchases.
final restockPurchasesProvider =
    StreamProvider.autoDispose<List<RestockPurchase>>((ref) {
      final repo = ref.watch(restockRepositoryProvider);
      return repo.watchAllRestockPurchases();
    });

/// Stream of running parents balance ledger.
final parentsBalanceLedgerProvider =
    StreamProvider.autoDispose<ParentsBalanceLedger>((ref) {
      final repo = ref.watch(restockRepositoryProvider);
      return repo.watchParentsBalanceLedger();
    });
