import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sale_repository.dart';
import 'database_provider.dart';

/// Provider for SaleRepository instance.
final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SaleRepository(db);
});

/// Notifier managing current calendar date filter for sales history.
/// If null, displays all days. Defaults to today's date.
class SelectedSalesDateFilterNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime? date) {
    state = date;
  }
}

/// Current calendar date filter for sales history.
final selectedSalesDateFilterProvider =
    NotifierProvider<SelectedSalesDateFilterNotifier, DateTime?>(
      SelectedSalesDateFilterNotifier.new,
    );

/// Stream of sales with details based on the active date filter.
final salesWithDetailsProvider =
    StreamProvider.autoDispose<List<SaleWithDetails>>((ref) {
      final repo = ref.watch(saleRepositoryProvider);
      final filter = ref.watch(selectedSalesDateFilterProvider);
      return repo.watchSalesWithDetails(dateFilter: filter);
    });

/// Checks if a specific day's payout is locked.
final isDayLockedProvider = FutureProvider.family<bool, DateTime>((
  ref,
  date,
) async {
  final repo = ref.watch(saleRepositoryProvider);
  return repo.isDayLocked(date);
});
