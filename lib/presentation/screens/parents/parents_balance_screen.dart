import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/utils/formatters.dart';
import '../../providers/restock_providers.dart';
import '../../theme/app_theme.dart';

/// Screen managing produce restock funding and running repayment balance to parents.
class ParentsBalanceScreen extends ConsumerWidget {
  const ParentsBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(parentsBalanceLedgerProvider);
    final purchasesAsync = ref.watch(restockPurchasesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Parents' Balance Ledger")),
      body: CustomScrollView(
        slivers: [
          // Running Balance Summary Card
          SliverToBoxAdapter(
            child: ledgerAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (ledger) {
                final isOwed = ledger.outstandingBalanceCentavos > 0;
                final isOverpaid = ledger.outstandingBalanceCentavos < 0;

                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OUTSTANDING BALANCE OWED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatMoney(ledger.outstandingBalanceCentavos.abs()),
                        style: TextStyle(
                          color: isOverpaid
                              ? AppTheme.accentGreen
                              : Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOwed
                            ? 'Owed to parents for restock capital'
                            : isOverpaid
                            ? 'Overpaid / Credit with parents'
                            : 'All restock capital fully repaid',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL RESTOCK SPEND',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatMoney(ledger.totalRestockSpendCentavos),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'RETURNED VIA PAYOUTS',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatMoney(
                                  ledger.totalReturnedToParentsCentavos,
                                ),
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Section Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'RESTOCK PURCHASE ENTRIES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Purchases list
          purchasesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
            data: (purchases) {
              if (purchases.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No restock purchases recorded yet.\nTap "+ Add Restock Purchase" to log capital funding.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = purchases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryDark.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                color: AppTheme.primaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat.yMMMd().format(item.date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        formatMoney(item.amountCentavos),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: AppTheme.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.note != null &&
                                      item.note!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.note!,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              tooltip: 'Delete Entry',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      'Delete Restock Purchase?',
                                    ),
                                    content: Text(
                                      'Delete restock purchase of ${formatMoney(item.amountCentavos)}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentRed,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ref
                                      .read(restockRepositoryProvider)
                                      .deleteRestockPurchase(item.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: purchases.length),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Restock Purchase'),
        onPressed: () => _showAddRestockDialog(context, ref),
      ),
    );
  }

  static Future<void> _showAddRestockDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime pickedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Restock Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${DateFormat.yMMMd().format(pickedDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (Pesos)',
                  prefixText: 'P ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [500, 1000, 2000, 5000].map((pesos) {
                  return ActionChip(
                    label: Text('P$pesos'),
                    onPressed: () {
                      setState(() {
                        amountController.text = pesos.toString();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Supplier / Note (optional)',
                  hintText: 'e.g. 5 crates Cardava from Davao',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final centavos = parsePesoStringToCentavos(
                  amountController.text,
                );
                if (centavos == null || centavos <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                await ref
                    .read(restockRepositoryProvider)
                    .addRestockPurchase(
                      date: pickedDate,
                      amountCentavos: centavos,
                      note: noteController.text.trim().isNotEmpty
                          ? noteController.text.trim()
                          : null,
                    );

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save Purchase'),
            ),
          ],
        ),
      ),
    );
  }
}
