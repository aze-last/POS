import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/product_providers.dart';
import '../../providers/sync_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image_widget.dart';
import 'capital_history_sheet.dart';
import 'product_form_dialog.dart';

/// Full CRUD Product Management Screen for Banana POS.
///
/// Supports:
/// - Reorderable active list
/// - Prominent capital cost display ("Capital: P__/kg")
/// - Capital history inspection
/// - Soft-archiving with confirmation dialog
/// - Restoring archived products
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  int _selectedTabIndex = 0; // 0 = Active, 1 = Archived

  Future<void> _confirmArchive(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Archive ${product.name}?'),
        content: Text(
          '${product.name} will be hidden from the POS sales screen. Past sales and profit reports will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 44),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(productRepositoryProvider);
      await repo.archiveProduct(product.id);
      ref.read(syncStateProvider.notifier).triggerAutoSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} archived'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await repo.restoreProduct(product.id);
                ref.read(syncStateProvider.notifier).triggerAutoSync();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.dangerColor,
                      content: Text('Could not restore: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _restoreProduct(Product product) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.restoreProduct(product.id);
      ref.read(syncStateProvider.notifier).triggerAutoSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} restored to active catalog')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.dangerColor,
          content: Text(
            e.toString().replaceFirst('ProductValidationException: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteArchived(Product product) async {
    final repo = ref.read(productRepositoryProvider);
    final hasSales = await repo.hasSalesOrExpenses(product.id);
    if (!mounted) return;

    if (hasSales) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Cannot Delete ${product.name}'),
          content: Text(
            '${product.name} has sales or expenses recorded in your history. It is kept archived so your financial reports and receipts remain accurate.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${product.name}?'),
        content: Text(
          'Are you sure you want to permanently delete ${product.name}? It has no sales history and will be completely removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await repo.deleteProduct(product.id);
      ref.read(syncStateProvider.notifier).triggerAutoSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} permanently deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProductsAsync = ref.watch(activeProductsProvider);
    final archivedProductsAsync = ref.watch(archivedProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banana Catalog'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTabIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: activeProductsAsync.when(
                          data: (items) => Text(
                            'Active (${items.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTabIndex == 0
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          loading: () => const Text('Active'),
                          error: (_, _) => const Text('Active'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTabIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: archivedProductsAsync.when(
                          data: (items) => Text(
                            'Archived (${items.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTabIndex == 1
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          loading: () => const Text('Archived'),
                          error: (_, _) => const Text('Archived'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _selectedTabIndex == 0
          ? _buildActiveList(activeProductsAsync)
          : _buildArchivedList(archivedProductsAsync),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductFormDialog.show(context),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Variety',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildActiveList(AsyncValue<List<Product>> activeAsync) {
    return activeAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No active banana products.\nTap + Add Variety below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: products.length,
          onReorderItem: (oldIndex, newIndex) {
            final items = List<Product>.from(products);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            ref
                .read(productRepositoryProvider)
                .reorderProducts(items.map((e) => e.id).toList());
          },
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              key: ValueKey(product.id),
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => ProductFormDialog.show(context, product: product),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      // Drag handle icon (min 48dp hit area)
                      ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.drag_indicator,
                            size: 26,
                            color: AppTheme.borderSubtle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Product Photo
                      ProductImageWidget(
                        imagePath: product.imagePath,
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 12),
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Prominent Capital Display (Spec Section 5.2)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.amber.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    'Capital: ${formatMoney(product.capitalCentavos)}/kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sell: ${formatMoney(product.defaultPriceCentavos)}/kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action buttons: History & Archive
                      IconButton(
                        icon: const Icon(
                          Icons.history,
                          color: AppTheme.textSecondary,
                        ),
                        tooltip: 'Capital History',
                        onPressed: () =>
                            CapitalHistorySheet.show(context, product),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.dangerColor,
                        ),
                        tooltip: 'Archive',
                        onPressed: () => _confirmArchive(product),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading catalog: $err')),
    );
  }

  Widget _buildArchivedList(AsyncValue<List<Product>> archivedAsync) {
    return archivedAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No archived products.',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.grey.shade100,
              child: ListTile(
                leading: ProductImageWidget(
                  imagePath: product.imagePath,
                  width: 44,
                  height: 44,
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                subtitle: Text(
                  'Capital: ${formatMoney(product.capitalCentavos)}/kg · Sell: ${formatMoney(product.defaultPriceCentavos)}/kg',
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.unarchive_outlined),
                      label: const Text('Restore'),
                      onPressed: () => _restoreProduct(product),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                        color: AppTheme.dangerColor,
                      ),
                      tooltip: 'Delete Permanently',
                      onPressed: () => _confirmDeleteArchived(product),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
