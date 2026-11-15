import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sale_repository.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../providers/sale_providers.dart';
import '../../theme/app_theme.dart';
import 'receipt_dialog.dart';
import 'weighing_bottom_sheet.dart';

/// Full checkout and cart drawer sheet.
class CartSheet extends ConsumerStatefulWidget {
  const CartSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CartSheet(),
    );
  }

  @override
  ConsumerState<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends ConsumerState<CartSheet> {
  late final TextEditingController _chargedController;
  late final TextEditingController _paidController;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    final chargedPesos =
        '${cart.chargedCentavos ~/ 100}.${(cart.chargedCentavos % 100).toString().padLeft(2, '0')}';
    final paidPesos = cart.paidCentavos > 0
        ? '${cart.paidCentavos ~/ 100}.${(cart.paidCentavos % 100).toString().padLeft(2, '0')}'
        : '';

    _chargedController = TextEditingController(text: chargedPesos);
    _paidController = TextEditingController(text: paidPesos);
  }

  @override
  void dispose() {
    _chargedController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  void _syncChargedText(int centavos) {
    _chargedController.text =
        '${centavos ~/ 100}.${(centavos % 100).toString().padLeft(2, '0')}';
  }

  void _syncPaidText(int centavos) {
    _paidController.text =
        '${centavos ~/ 100}.${(centavos % 100).toString().padLeft(2, '0')}';
    ref.read(cartProvider.notifier).setPaidAmount(centavos);
  }

  Future<void> _completeSale() async {
    final cart = ref.read(cartProvider);
    if (!cart.canComplete || _isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      final saleRepo = ref.read(saleRepositoryProvider);
      final linesInput = cart.lines.map((l) {
        return SaleLineInput(
          productId: l.productId,
          productName: l.productName,
          weight: l.weight,
          pricePerKgCentavos: l.pricePerKgCentavos,
          capitalPerKgCentavos: l.capitalPerKgCentavos,
        );
      }).toList();

      final result = await saleRepo.completeSale(
        lines: linesInput,
        chargedCentavos: cart.chargedCentavos,
        paidCentavos: cart.paidCentavos,
      );

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        Navigator.of(context).pop(); // Close cart sheet
        ReceiptDialog.show(context, result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.dangerColor,
            content: Text('Failed to complete sale: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: AppTheme.surfaceLight,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Cart (${cart.totalItemCount})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 16),

            // Cart Lines List
            Expanded(
              child: cart.lines.isEmpty
                  ? const Center(
                      child: Text(
                        'Cart is empty.\nTap bananas on the grid to weigh and add.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: cart.lines.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final line = cart.lines[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            line.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(
                            '${line.weight.formatKg()} @ ${formatMoney(line.pricePerKgCentavos)}/kg',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatMoney(line.lineValueCentavos),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.dangerColor,
                                ),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .removeLine(line.id);
                                  if (cart.lines.length <= 1) {
                                    _chargedController.text = '0.00';
                                  } else {
                                    final newExact =
                                        cart.exactTotalCentavos -
                                        line.lineValueCentavos;
                                    _syncChargedText(newExact);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            // Tap to edit line
                            final products = await ref
                                .read(productRepositoryProvider)
                                .getActiveProducts();
                            final prod = products.firstWhere(
                              (p) => p.id == line.productId,
                            );
                            if (context.mounted) {
                              WeighingBottomSheet.show(
                                context,
                                product: prod,
                                lineToEdit: line,
                              );
                            }
                          },
                        );
                      },
                    ),
            ),

            if (cart.lines.isNotEmpty) ...[
              const Divider(height: 20),

              // Exact Total & Rounding Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Exact Total:', style: TextStyle(fontSize: 16)),
                  Text(
                    formatMoney(cart.exactTotalCentavos),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Amount to charge (prefilled with exact total, with round down/up buttons)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _chargedController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount to Charge',
                        prefixText: 'P ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final c = parsePesoStringToCentavos(val);
                        ref.read(cartProvider.notifier).setChargedAmount(c);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // One-tap Round Down
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () {
                      ref.read(cartProvider.notifier).roundDownCharged();
                      _syncChargedText(ref.read(cartProvider).chargedCentavos);
                    },
                    child: const Text(
                      'Round\nDown',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // One-tap Round Up
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () {
                      ref.read(cartProvider.notifier).roundUpCharged();
                      _syncChargedText(ref.read(cartProvider).chargedCentavos);
                    },
                    child: const Text(
                      'Round\nUp',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

              if (cart.discountCentavos > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Discount: -${formatMoney(cart.discountCentavos)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Amount Paid & Quick Cash Chips
              TextFormField(
                controller: _paidController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  prefixText: 'P ',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  final c = parsePesoStringToCentavos(val) ?? 0;
                  ref.read(cartProvider.notifier).setPaidAmount(c);
                },
              ),
              const SizedBox(height: 8),

              // Quick cash buttons (50, 100, 200, 500, 1000, exact)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text('Exact'),
                      onPressed: () => _syncPaidText(cart.chargedCentavos),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      label: const Text('P50'),
                      onPressed: () => _syncPaidText(5000),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      label: const Text('P100'),
                      onPressed: () => _syncPaidText(10000),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      label: const Text('P200'),
                      onPressed: () => _syncPaidText(20000),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      label: const Text('P500'),
                      onPressed: () => _syncPaidText(50000),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      label: const Text('P1,000'),
                      onPressed: () => _syncPaidText(100000),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Live Change Display Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cart.isPaidSufficient
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: cart.isPaidSufficient
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cart.isPaidSufficient ? 'CHANGE DUE:' : 'REMAINING DUE:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: cart.isPaidSufficient
                            ? Colors.green.shade800
                            : AppTheme.dangerColor,
                      ),
                    ),
                    Text(
                      cart.isPaidSufficient
                          ? formatMoney(cart.changeCentavos)
                          : formatMoney(
                              cart.chargedCentavos - cart.paidCentavos,
                            ),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cart.isPaidSufficient
                            ? Colors.green.shade900
                            : AppTheme.dangerColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Complete Sale Action Button
              ElevatedButton(
                onPressed: cart.canComplete && !_isCompleting
                    ? _completeSale
                    : null,
                child: _isCompleting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Complete Sale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
