import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/utils/formatters.dart';
import '../../providers/payout_providers.dart';
import '../../theme/app_theme.dart';

/// Interactive weekly summary view aggregating 7-day Monday–Sunday settlements.
class WeeklySummaryView extends ConsumerWidget {
  const WeeklySummaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRefDate = ref.watch(selectedWeeklyDateProvider);
    final weeklyAsync = ref.watch(weeklySummaryStateProvider(selectedRefDate));

    return Column(
      children: [
        // Week Navigation Bar
        _WeekNavigationBar(selectedDate: selectedRefDate),

        // Main Weekly Content
        Expanded(
          child: weeklyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error loading weekly summary: $e'),
              ),
            ),
            data: (weeklyState) {
              final calc = weeklyState.calculation;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Big Highlight Cards for Parents & Salary
                    Row(
                      children: [
                        Expanded(
                          child: _WeeklyKpiCard(
                            label: 'TOTAL TO PARENTS',
                            value: formatMoney(calc.totalToParentsCentavos),
                            subtitle: 'Capital + Spoilage for week',
                            badgeText: '${calc.lockedDaysCount}/7 days locked',
                            valueColor: AppTheme.primaryDark,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _WeeklyKpiCard(
                            label: 'MY TOTAL SALARY',
                            value: formatMoney(calc.totalSalaryCentavos),
                            subtitle: 'Your weekly earnings',
                            valueColor: AppTheme.accentGreen,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Weekly Consolidated Financials Card
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
                                'WEEKLY FINANCIAL CONSOLIDATION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Icon(
                                Icons.date_range_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _MetricRow(
                            label: 'Total Sales (Charged)',
                            value: formatMoney(calc.totalSalesCentavos),
                          ),
                          _MetricRow(
                            label: 'Produce Capital Sold',
                            value:
                                '-${formatMoney(calc.totalCapitalSoldCentavos)}',
                          ),
                          _MetricRow(
                            label: 'Gross Profit',
                            value: formatMoney(calc.totalGrossProfitCentavos),
                            isBold: true,
                          ),
                          _MetricRow(
                            label: 'Spoilage Losses',
                            value:
                                '-${formatMoney(calc.totalSpoilageCentavos)}',
                          ),
                          _MetricRow(
                            label: 'Operational Expenses',
                            value:
                                '-${formatMoney(calc.totalOtherExpensesCentavos)}',
                          ),
                          const Divider(),
                          _MetricRow(
                            label: 'Net Profit',
                            value: formatMoney(calc.totalNetProfitCentavos),
                            isBold: true,
                            fontSize: 16,
                            valueColor: calc.totalNetProfitCentavos >= 0
                                ? AppTheme.accentGreen
                                : AppTheme.accentRed,
                          ),
                          const SizedBox(height: 4),
                          _MetricRow(
                            label:
                                'Reserve Cash (${calc.hasShortfall ? 'Deficit' : 'Surplus'})',
                            value: formatMoney(calc.totalReserveCentavos),
                            fontSize: 15,
                            isBold: true,
                            valueColor: calc.hasShortfall
                                ? AppTheme.accentRed
                                : AppTheme.primaryDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Day-by-Day 7-Day Breakdown Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DAY-BY-DAY BREAKDOWN (MON–SUN)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Tap day to open',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 7 Daily Rows
                    ...calc.days.map((day) {
                      return _DaySummaryCard(
                        day: day,
                        onTap: () {
                          // Switch to daily summary for this specific day
                          ref
                              .read(selectedDailySummaryDateProvider.notifier)
                              .setDate(day.date);
                          ref
                              .read(summaryViewModeProvider.notifier)
                              .setMode(SummaryViewMode.daily);
                        },
                      );
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekNavigationBar extends ConsumerWidget {
  final DateTime selectedDate;

  const _WeekNavigationBar({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monday = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - (selectedDate.weekday - 1),
    );
    final sunday = monday.add(const Duration(days: 6));

    final now = DateTime.now();
    final thisMonday = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final isCurrentWeek =
        monday.year == thisMonday.year &&
        monday.month == thisMonday.month &&
        monday.day == thisMonday.day;

    final weekRangeText =
        '${DateFormat.MMMd().format(monday)} – ${DateFormat.MMMd().format(sunday)}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Week',
            onPressed: () {
              ref.read(selectedWeeklyDateProvider.notifier).previousWeek();
            },
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.date_range, size: 16),
                    label: Text(
                      weekRangeText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        ref
                            .read(selectedWeeklyDateProvider.notifier)
                            .setDate(picked);
                      }
                    },
                  ),
                  if (!isCurrentWeek) ...[
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(selectedWeeklyDateProvider.notifier)
                            .setThisWeek();
                      },
                      child: const Text('This Week'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Week',
            onPressed: () {
              ref.read(selectedWeeklyDateProvider.notifier).nextWeek();
            },
          ),
        ],
      ),
    );
  }
}

class _WeeklyKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final String? badgeText;
  final Color valueColor;
  final Color backgroundColor;

  const _WeeklyKpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.badgeText,
    required this.valueColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _MetricRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 13,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  final dynamic day; // WeeklyDaySummary
  final VoidCallback onTap;

  const _DaySummaryCard({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = day.date as DateTime;
    final dayName = DateFormat('E, MMM d').format(date);
    final hasActivity =
        day.salesCentavos > 0 ||
        day.spoilageCentavos > 0 ||
        day.otherExpensesCentavos > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: day.isLocked
              ? AppTheme.warningAmber.withValues(alpha: 0.6)
              : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Day & Status Indicator
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (day.isLocked) ...[
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 12,
                            color: AppTheme.warningAmber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PAID OUT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningAmber,
                            ),
                          ),
                        ],
                      ),
                    ] else if (hasActivity) ...[
                      const Text(
                        'Active / Open',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'No Sales',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // To Parents & Salary Columns
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'To Parents: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          formatMoney(day.toParentsCentavos),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Salary: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          formatMoney(day.salaryCentavos),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
