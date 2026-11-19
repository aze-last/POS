import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/weight.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/expense_providers.dart';
import '../../providers/payout_providers.dart';
import '../../theme/app_theme.dart';
import '../expenses/expenses_screen.dart';
import 'payout_section.dart';
import 'weekly_summary_view.dart';

/// Screen providing daily and weekly financial consolidation, volume metrics, and payout settlement.
class DailySummaryScreen extends ConsumerWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(summaryViewModeProvider);
    final selectedDate = ref.watch(selectedDailySummaryDateProvider);
    final summaryAsync = ref.watch(dailySummaryStateProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewMode == SummaryViewMode.daily
              ? 'Daily Summary'
              : 'Weekly Summary',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: viewMode == SummaryViewMode.daily
                ? 'Pick Date'
                : 'Pick Week',
            onPressed: () async {
              final initial = viewMode == SummaryViewMode.daily
                  ? selectedDate
                  : ref.read(selectedWeeklyDateProvider);
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                if (viewMode == SummaryViewMode.daily) {
                  ref
                      .read(selectedDailySummaryDateProvider.notifier)
                      .setDate(picked);
                } else {
                  ref.read(selectedWeeklyDateProvider.notifier).setDate(picked);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Toggle for Daily vs Weekly
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            width: double.infinity,
            child: SegmentedButton<SummaryViewMode>(
              segments: const [
                ButtonSegment(
                  value: SummaryViewMode.daily,
                  label: Text('Daily Payout'),
                  icon: Icon(Icons.today_outlined, size: 18),
                ),
                ButtonSegment(
                  value: SummaryViewMode.weekly,
                  label: Text('Weekly Payout'),
                  icon: Icon(Icons.calendar_view_week_outlined, size: 18),
                ),
              ],
              selected: {viewMode},
              onSelectionChanged: (newSet) {
                ref
                    .read(summaryViewModeProvider.notifier)
                    .setMode(newSet.first);
              },
            ),
          ),

          if (viewMode == SummaryViewMode.weekly)
            const Expanded(child: WeeklySummaryView())
          else ...[
            // Date Selector Bar
            _SummaryDateBar(
              selectedDate: selectedDate,
              onSelectDate: (d) => ref
                  .read(selectedDailySummaryDateProvider.notifier)
                  .setDate(d),
            ),

            // Main Scrollable Summary
            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error loading summary: $e')),
                data: (summary) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top KPI Overview Cards
                        Row(
                          children: [
                            Expanded(
                              child: _KpiCard(
                                label: 'TOTAL CHARGED',
                                value: formatMoney(
                                  summary.totalChargedCentavos,
                                ),
                                subtitle: summary.totalDiscountsCentavos > 0
                                    ? '${summary.salesCount} sales (${formatMoney(summary.totalDiscountsCentavos)} discounts)'
                                    : '${summary.salesCount} sales completed',
                                valueColor: AppTheme.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _KpiCard(
                                label: 'GROSS PROFIT',
                                value: formatMoney(summary.grossProfitCentavos),
                                subtitle:
                                    'Capital: ${formatMoney(summary.capitalSoldCentavos)}',
                                valueColor: summary.grossProfitCentavos >= 0
                                    ? AppTheme.accentGreen
                                    : AppTheme.accentRed,
                              ),
                            ),
                          ],
                        ),
                        if (summary.editedSalesCount > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 16,
                                  color: Colors.blue.shade800,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${summary.editedSalesCount} ${summary.editedSalesCount == 1 ? 'sale' : 'sales'} edited today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (summary.showReopenedEditBanner) ...[
                          const SizedBox(height: 12),
                          _ReopenedPayoutBanner(summary: summary),
                        ],
                        if (summary.totalDiscountsCentavos > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer_outlined,
                                      size: 16,
                                      color: Colors.deepOrange,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Total Discounts Given',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '-${formatMoney(summary.totalDiscountsCentavos)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Produce Sold by Variety Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'VOLUME SOLD BY VARIETY',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Icon(
                                    Icons.scale_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (summary.productGramsSold.isEmpty) ...[
                                const Text(
                                  'No bananas sold yet on this date.',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ] else ...[
                                ...summary.productGramsSold.entries.map((
                                  entry,
                                ) {
                                  final weight = Weight.fromGrams(entry.value);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          weight.formatKg(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: AppTheme.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Expenses & Spoilage Quick Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expenses & Spoilage',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Loss: ${formatMoney(summary.spoilageCentavos)} · Other: ${formatMoney(summary.otherExpensesCentavos)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Manage'),
                                onPressed: () {
                                  ref
                                      .read(
                                        selectedExpensesDateProvider.notifier,
                                      )
                                      .setDate(selectedDate);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ExpensesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Complete Payout Settlement Section
                        PayoutSection(summary: summary),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryDateBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const _SummaryDateBar({
    required this.selectedDate,
    required this.onSelectDate,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Today'),
            selected: _isSameDay(selectedDate, today),
            onSelected: (_) => onSelectDate(today),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Yesterday'),
            selected: _isSameDay(selectedDate, yesterday),
            onSelected: (_) => onSelectDate(yesterday),
          ),
          const SizedBox(width: 8),
          if (!_isSameDay(selectedDate, today) &&
              !_isSameDay(selectedDate, yesterday))
            ChoiceChip(
              label: Text(DateFormat.yMMMd().format(selectedDate)),
              selected: true,
              onSelected: (_) {},
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color valueColor;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ReopenedPayoutBanner extends StatelessWidget {
  final DailySummaryState summary;

  const _ReopenedPayoutBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    final payout = summary.payout;
    if (payout == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningAmber, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningAmber,
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sales changed since this day was paid out. Review the payout before marking it again.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.amber.shade300, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREVIOUSLY SAVED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Parents: ${formatMoney(payout.toParentsCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Salary: ${formatMoney(payout.salaryCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Reserve: ${formatMoney(payout.reserveCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEW SUGGESTED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Parents: ${formatMoney(summary.calculation.suggestedToParentsCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'Salary: ${formatMoney(summary.calculation.suggestedSalaryCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'Reserve: ${formatMoney(summary.calculation.reserveCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
