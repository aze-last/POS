import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/utils/formatters.dart';
import '../../providers/backup_providers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../expenses/expenses_screen.dart';
import '../parents/parents_balance_screen.dart';
import '../products/products_screen.dart';
import '../sales/sales_history_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/update_dialog.dart';
import '../summary/daily_summary_screen.dart';
import '../../providers/update_providers.dart';
import 'cart_sheet.dart';
import 'weighing_bottom_sheet.dart';

/// Main Point of Sale Screen for Banana POS.
///
/// Designed for:
/// - Direct sunlight readability (high contrast bold typography)
/// - Single-hand stall ergonomics
/// - Minimal taps to complete weighing, carting, and checkout
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  bool _updateDialogShown = false;
  bool _updateBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    // Clean up any lingering temporary APKs from previous updates
    Future.microtask(() {
      ref.read(updateServiceProvider).cleanOldUpdateFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeProductsAsync = ref.watch(activeProductsProvider);
    final cart = ref.watch(cartProvider);
    final updateAsync = ref.watch(availableUpdateProvider);

    // Update notification handling:
    // Never interrupt a sale. If cart is not empty, show dismissible banner instead of modal.
    final availableUpdate = updateAsync.value;
    if (availableUpdate != null && cart.lines.isEmpty && !_updateDialogShown) {
      _updateDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        final versionInfo = await ref.read(installedVersionProvider.future);
        if (!context.mounted) return;
        UpdateDialog.show(
          context,
          release: availableUpdate,
          currentVersion: versionInfo.version,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.storefront, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text('Banana POS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Daily Summary',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailySummaryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Sales History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
            onSelected: (val) {
              if (val == 'expenses') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                );
              } else if (val == 'parents') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ParentsBalanceScreen(),
                  ),
                );
              } else if (val == 'products') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                );
              } else if (val == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'expenses',
                child: Row(
                  children: [
                    Icon(Icons.money_off_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Expenses & Losses'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'parents',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 20),
                    SizedBox(width: 12),
                    Text("Parents' Balance"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'products',
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Banana Varieties'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings & Backup'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Non-interruptive update banner when cart has items
          if (availableUpdate != null &&
              cart.lines.isNotEmpty &&
              !_updateBannerDismissed)
            Container(
              color: const Color(0xFFEFF6FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.system_update_rounded,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final versionInfo = await ref.read(
                          installedVersionProvider.future,
                        );
                        if (context.mounted) {
                          UpdateDialog.show(
                            context,
                            release: availableUpdate,
                            currentVersion: versionInfo.version,
                          );
                        }
                      },
                      child: Text(
                        'New update ${availableUpdate.rawTag} available. Tap to view.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF1E40AF),
                    ),
                    tooltip: 'Dismiss update notice',
                    onPressed: () =>
                        setState(() => _updateBannerDismissed = true),
                  ),
                ],
              ),
            ),
          if (ref.watch(backupNudgeNeededProvider))
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: Container(
                color: const Color(0xFFFEF3C7),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warningAmber,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Weekly backup reminder: Tap to protect sales data',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF92400E),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: activeProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No active banana varieties.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Variety to Catalog'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProductsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    cart.lines.isNotEmpty ? 96 : 24,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            WeighingBottomSheet.show(context, product: product),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                      '${formatMoney(product.defaultPriceCentavos)}/kg',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cap: ${formatMoney(product.capitalCentavos)}/kg',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
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
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      bottomSheet: cart.lines.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    minimumSize: const Size.fromHeight(54),
                  ),
                  onPressed: () => CartSheet.show(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Total: ${formatMoney(cart.chargedCentavos)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Row(
                        children: [
                          Text('Checkout', style: TextStyle(fontSize: 16)),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
