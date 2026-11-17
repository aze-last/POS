import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/sale_repository.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/sale_providers.dart';
import '../../theme/app_theme.dart';
import 'edit_sale_dialog.dart';
import 'sale_detail_sheet.dart';
import 'sale_edit_history_dialog.dart';
import 'void_confirmation_dialog.dart';

/// Screen displaying the complete historical audit log of sales.
///
/// Ergonomics:
/// - Minimal clicking: 1-tap quick filter chips (Today, Yesterday, All Time)
/// - Grouped chronologically by calendar day
/// - Prominent sunlight-readable numbers and high-contrast badges
/// - Voided sales are struck-through and clearly excluded from active totals
class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDateFilter = ref.watch(selectedSalesDateFilterProvider);
    final salesAsync = ref.watch(salesWithDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Pick Custom Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: activeDateFilter ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                ref
                    .read(selectedSalesDateFilterProvider.notifier)
                    .setDate(DateTime(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1-Tap Quick Date Filter Bar
          _DateFilterBar(
            selectedDate: activeDateFilter,
            onSelectDate: (date) {
              ref.read(selectedSalesDateFilterProvider.notifier).setDate(date);
            },
          ),

          // Main Sales List and Financial Banner
          Expanded(
            child: salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error loading sales: $err',
                    style: const TextStyle(color: AppTheme.accentRed),
                  ),
                ),
              ),
              data: (sales) {
                // Compute summary metrics (strictly excluding voided sales)
                final activeSales = sales.where((s) => !s.sale.voided).toList();
                final voidedCount = sales.length - activeSales.length;
                final totalCharged = activeSales.fold<int>(
                  0,
                  (sum, s) => sum + s.sale.chargedCentavos,
                );
                final totalProfit = activeSales.fold<int>(
                  0,
                  (sum, s) => sum + s.profitCentavos,
                );

                return CustomScrollView(
                  slivers: [
                    // Summary Banner
                    SliverToBoxAdapter(
                      child: _SalesSummaryBanner(
                        totalChargedCentavos: totalCharged,
                        totalProfitCentavos: totalProfit,
                        activeSalesCount: activeSales.length,
                        voidedSalesCount: voidedCount,
                      ),
                    ),

                    if (sales.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptySalesView(
                          hasFilter: activeDateFilter != null,
                          onClearFilter: () {
                            ref
                                .read(selectedSalesDateFilterProvider.notifier)
                                .setDate(null);
                          },
                        ),
                      )
                    else
                      ..._buildGroupedDaySlivers(context, ref, sales),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Groups sales by calendar day and returns slivers for each group.
  List<Widget> _buildGroupedDaySlivers(
    BuildContext context,
    WidgetRef ref,
    List<SaleWithDetails> sales,
  ) {
    // Map by calendar date key (YYYY-MM-DD)
    final Map<String, List<SaleWithDetails>> grouped = {};
    for (final sale in sales) {
      final key = DateFormat('yyyy-MM-dd').format(sale.sale.createdAt);
      grouped.putIfAbsent(key, () => []).add(sale);
    }

    final slivers = <Widget>[];

    for (final entry in grouped.entries) {
      final daySales = entry.value;
      final firstSaleDate = daySales.first.sale.createdAt;
      final activeDaySales = daySales.where((s) => !s.sale.voided).toList();
      final dayCharged = activeDaySales.fold<int>(
        0,
        (sum, s) => sum + s.sale.chargedCentavos,
      );
      final dayProfit = activeDaySales.fold<int>(
        0,
        (sum, s) => sum + s.profitCentavos,
      );

      // Section Header
      slivers.add(
        SliverToBoxAdapter(
          child: _DayHeader(
            date: firstSaleDate,
            dayChargedCentavos: dayCharged,
            dayProfitCentavos: dayProfit,
            activeCount: activeDaySales.length,
          ),
        ),
      );

      // Section Cards
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final saleWithDetails = daySales[index];
              return _SaleCard(
                saleWithDetails: saleWithDetails,
                onTap: () {
                  SaleDetailSheet.show(
                    context,
                    saleWithDetails: saleWithDetails,
                  );
                },
              );
            }, childCount: daySales.length),
          ),
        ),
      );
    }

    // Bottom padding
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));

    return slivers;
  }
}

/// Horizontal bar with quick chips for minimal clicking.
class _DateFilterBar extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onSelectDate;

  const _DateFilterBar({
    required this.selectedDate,
    required this.onSelectDate,
  });

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final isToday = _isSameDay(selectedDate, today);
    final isYesterday = _isSameDay(selectedDate, yesterday);
    final isAll = selectedDate == null;
    final isCustom = !isToday && !isYesterday && !isAll;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Today'),
              selected: isToday,
              onSelected: (_) => onSelectDate(today),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Yesterday'),
              selected: isYesterday,
              onSelected: (_) => onSelectDate(yesterday),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('All Time'),
              selected: isAll,
              onSelected: (_) => onSelectDate(null),
            ),
            if (isCustom && selectedDate != null) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(DateFormat.yMMMd().format(selectedDate!)),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Financial summary banner for active filter.
class _SalesSummaryBanner extends StatelessWidget {
  final int totalChargedCentavos;
  final int totalProfitCentavos;
  final int activeSalesCount;
  final int voidedSalesCount;

  const _SalesSummaryBanner({
    required this.totalChargedCentavos,
    required this.totalProfitCentavos,
    required this.activeSalesCount,
    required this.voidedSalesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL SALES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(totalChargedCentavos),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$activeSalesCount sale${activeSalesCount == 1 ? '' : 's'}'
                  '${voidedSalesCount > 0 ? ' ($voidedSalesCount voided)' : ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(height: 48, width: 1, color: Colors.white24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GROSS PROFIT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(totalProfitCentavos),
                  style: const TextStyle(
                    color: AppTheme.accentGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Snapshotted capital',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Day group header showing date, day total, and locked status badge.
class _DayHeader extends ConsumerWidget {
  final DateTime date;
  final int dayChargedCentavos;
  final int dayProfitCentavos;
  final int activeCount;

  const _DayHeader({
    required this.date,
    required this.dayChargedCentavos,
    required this.dayProfitCentavos,
    required this.activeCount,
  });

  String _formatDayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMM d, yyyy').format(d);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLockedAsync = ref.watch(isDayLockedProvider(date));
    final isLocked = isLockedAsync.value ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                _formatDayLabel(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: AppTheme.warningAmber),
                      SizedBox(width: 2),
                      Text(
                        'Locked',
                        style: TextStyle(
                          color: AppTheme.warningAmber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Text(
            '${formatMoney(dayChargedCentavos)} (${formatMoney(dayProfitCentavos)} profit)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact touch-friendly card representing an individual sale.
class _SaleCard extends ConsumerWidget {
  final SaleWithDetails saleWithDetails;
  final VoidCallback onTap;

  const _SaleCard({required this.saleWithDetails, required this.onTap});

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(saleRepositoryProvider);
    final isLocked = await repo.isDayLocked(saleWithDetails.sale.createdAt);

    if (isLocked) {
      if (!context.mounted) return;
      final reopen = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Day Payout Locked'),
          content: const Text('This day is paid out. Reopen it first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.warningAmber,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Reopen Day'),
            ),
          ],
        ),
      );

      if (reopen == true) {
        await repo.reopenDay(saleWithDetails.sale.createdAt);
        if (!context.mounted) return;
        await EditSaleDialog.show(context, saleWithDetails);
      }
      return;
    }

    if (context.mounted) {
      await EditSaleDialog.show(context, saleWithDetails);
    }
  }

  Future<void> _handleVoid(BuildContext context, WidgetRef ref) async {
    await VoidConfirmationDialog.show(context, ref, saleWithDetails);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sale = saleWithDetails.sale;
    final items = saleWithDetails.items;
    final isVoided = sale.voided;

    // Concise summary of items for single-glance reading
    final itemsSummary = items
        .map(
          (item) =>
              '${item.productNameSnapshot} ${Weight.fromGrams(item.grams).formatKg()}',
        )
        .join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: isVoided ? Colors.grey.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isVoided
              ? AppTheme.accentRed.withValues(alpha: 0.4)
              : Colors.grey.shade300,
          width: isVoided ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: ID, Time, EDITED badge, VOIDED badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Sale #${sale.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: isVoided
                                ? AppTheme.textSecondary
                                : AppTheme.primaryDark,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(sale.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (sale.editCount > 0)
                          GestureDetector(
                            onTap: () => SaleEditHistoryDialog.show(
                              context,
                              saleId: sale.id,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 13,
                                    color: Colors.blue.shade800,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Edited',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isVoided)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'VOIDED',
                        style: TextStyle(
                          color: AppTheme.accentRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else if (saleWithDetails.discountCentavos > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Saved ${formatMoney(saleWithDetails.discountCentavos)}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Items preview
              Text(
                '${items.length} item${items.length == 1 ? '' : 's'}: $itemsSummary',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isVoided
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 10),

              // Bottom financial row with quick Edit & Void actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount Charged
                  Text(
                    formatMoney(sale.chargedCentavos),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isVoided
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  // Profit indicator or quick actions
                  if (!isVoided)
                    Flexible(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            '+${formatMoney(saleWithDetails.profitCentavos)} profit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: saleWithDetails.profitCentavos >= 0
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRed,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _handleEdit(context, ref),
                            child: const Text('Edit'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.accentRed,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _handleVoid(context, ref),
                            child: const Text('Void'),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      'Excluded from totals',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.accentRed,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state view when no sales exist.
class _EmptySalesView extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClearFilter;

  const _EmptySalesView({required this.hasFilter, required this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No sales recorded',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'No sales found for the selected date filter.'
                  : 'Complete a checkout on the POS screen to record sales.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('View All Time'),
                onPressed: onClearFilter,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
