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

/// Screen providing daily financial consolidation, volume metrics, and payout settlement.
class DailySummaryScreen extends ConsumerWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDailySummaryDateProvider);
    final summaryAsync = ref.watch(dailySummaryStateProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Pick Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                ref
                    .read(selectedDailySummaryDateProvider.notifier)
                    .setDate(picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Bar
          _SummaryDateBar(
            selectedDate: selectedDate,
            onSelectDate: (d) =>
                ref.read(selectedDailySummaryDateProvider.notifier).setDate(d),
          ),

          // Main Scrollable Summary
          Expanded(
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading summary: $e')),
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
                              value: formatMoney(summary.totalChargedCentavos),
                              subtitle: '${summary.salesCount} sales completed',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              ...summary.productGramsSold.entries.map((entry) {
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
                                    .read(selectedExpensesDateProvider.notifier)
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
