import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';

/// Modal bottom sheet showing immutable capital history for a product.
class CapitalHistorySheet extends ConsumerWidget {
  final Product product;

  const CapitalHistorySheet({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CapitalHistorySheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(capitalHistoryProvider(product.id));
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

    return Material(
      color: AppTheme.surfaceLight,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.name} Capital History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active Capital: ${formatMoney(product.capitalCentavos)}/kg',
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: historyAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No capital adjustments yet.\nCurrent capital was set at creation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = records[index];
                      final diff = item.newCentavos - item.oldCentavos;
                      final isIncrease = diff > 0;
                      final diffStr = isIncrease
                          ? '+${formatMoney(diff)}'
                          : '-${formatMoney(diff.abs())}';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        title: Row(
                          children: [
                            Text(
                              formatMoney(item.oldCentavos),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.arrow_forward, size: 16),
                            ),
                            Text(
                              '${formatMoney(item.newCentavos)}/kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          dateFormat.format(item.changedAt),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isIncrease
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isIncrease
                                  ? Colors.red.shade300
                                  : Colors.green.shade300,
                            ),
                          ),
                          child: Text(
                            diffStr,
                            style: TextStyle(
                              color: isIncrease
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
