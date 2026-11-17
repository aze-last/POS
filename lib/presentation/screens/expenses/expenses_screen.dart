import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/expense_providers.dart';
import '../../providers/payout_providers.dart';
import '../../theme/app_theme.dart';
import 'add_expense_dialog.dart';

/// Screen listing all operational expenses and produce spoilage for a selected day.
class ExpensesScreen extends ConsumerWidget {
  final DateTime? initialDate;

  const ExpensesScreen({super.key, this.initialDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedExpensesDateProvider);
    final expensesAsync = ref.watch(expensesForDayProvider(selectedDate));
    final summaryAsync = ref.watch(expenseSummaryForDayProvider(selectedDate));
    final isLockedAsync = ref.watch(payoutForDayProvider(selectedDate));
    final isLocked = isLockedAsync.value?.locked ?? false;
    final dailySummaryAsync = ref.watch(
      dailySummaryStateProvider(selectedDate),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & Losses'),
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
                ref.read(selectedExpensesDateProvider.notifier).setDate(picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date bar
          _ExpensesDateBar(
            selectedDate: selectedDate,
            onSelectDate: (d) =>
                ref.read(selectedExpensesDateProvider.notifier).setDate(d),
          ),

          // Summary banner with Salary Tracker
          summaryAsync.when(
            data: (summary) => _ExpensesSummaryHeader(
              spoilageCentavos: summary.spoilageCentavos,
              otherExpensesCentavos: summary.otherExpensesCentavos,
              isLocked: isLocked,
              dailySummary: dailySummaryAsync.value,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
          ),

          // Expenses list
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.money_off_csred_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No expenses or losses recorded today',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final item = expenses[index];
                    return _ExpenseCard(
                      expense: item,
                      isLocked: isLocked,
                      onDelete: () async {
                        if (isLocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Day is locked. Reopen day in Daily Summary to delete expenses.',
                              ),
                              backgroundColor: AppTheme.accentRed,
                            ),
                          );
                          return;
                        }

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Expense?'),
                            content: Text(
                              'Are you sure you want to delete this ${item.type} expense of ${formatMoney(item.amountCentavos)}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentRed,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(expenseRepositoryProvider)
                              .deleteExpense(item.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense / Loss'),
        onPressed: () async {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Day is locked. Reopen day in Daily Summary before adding expenses.',
                ),
                backgroundColor: AppTheme.accentRed,
              ),
            );
            return;
          }
          await AddExpenseDialog.show(context, date: selectedDate);
        },
      ),
    );
  }
}

class _ExpensesDateBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const _ExpensesDateBar({
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

class _ExpensesSummaryHeader extends StatelessWidget {
  final int spoilageCentavos;
  final int otherExpensesCentavos;
  final bool isLocked;
  final DailySummaryState? dailySummary;

  const _ExpensesSummaryHeader({
    required this.spoilageCentavos,
    required this.otherExpensesCentavos,
    required this.isLocked,
    this.dailySummary,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpenses = spoilageCentavos + otherExpensesCentavos;

    // Daily Salary calculations
    final calc = dailySummary?.calculation;
    final settings = dailySummary?.settings;
    final isPercent = settings?.salaryMode == 'percent';
    final targetSalary = isPercent
        ? (calc != null && calc.grossProfitCentavos > 0 && settings != null
              ? ((calc.grossProfitCentavos *
                            settings.salaryPercentBasisPoints) +
                        5000) ~/
                    10000
              : 0)
        : (settings?.fixedDailySalaryCentavos ?? 0);

    final currentSalary =
        calc?.actualSalaryCentavos ?? calc?.suggestedSalaryCentavos ?? 0;
    final isSalaryCapped = calc?.isSalaryCapped ?? false;
    final hasSales = (dailySummary?.salesCount ?? 0) > 0;
    final isZeroSalary = currentSalary <= 0;

    // Color indicator for remaining salary
    final Color salaryColor;
    if (isZeroSalary && (hasSales || totalExpenses > 0)) {
      salaryColor = AppTheme.accentRed;
    } else if (isSalaryCapped) {
      salaryColor = AppTheme.warningAmber;
    } else {
      salaryColor = AppTheme.accentGreen;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Header + Locked Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL EXPENSES & LOSSES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
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
                  child: const Text(
                    '🔒 Locked Day',
                    style: TextStyle(
                      color: AppTheme.warningAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Expense total + Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatMoney(totalExpenses),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentRed,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Spoilage: ${formatMoney(spoilageCentavos)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Transport/Other: ${formatMoney(otherExpensesCentavos)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (dailySummary != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            // Row 3: Daily Salary Tracker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: AppTheme.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'DAILY SALARY TRACKER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    isPercent
                        ? '${((settings?.salaryPercentBasisPoints ?? 3000) / 100).toStringAsFixed(0)}% of Profit'
                        : 'Fixed Target: ${formatMoney(targetSalary)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 4: Salary values
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Salary',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(targetSalary),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'SALARY LEFT TODAY',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(currentSalary),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: salaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 5: Salary Warning or Status Banner
            if (isZeroSalary && (hasSales || totalExpenses > 0)) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.accentRed,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning: Expenses (${formatMoney(totalExpenses)}) have exhausted today\'s profits! P0.00 salary left today.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isSalaryCapped && currentSalary > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningAmber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warningAmber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low Salary Warning: Expenses reduced your salary to ${formatMoney(currentSalary)} (${formatMoney(targetSalary - currentSalary)} below your target).',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!hasSales) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No sales recorded today yet. Complete sales in POS to build up your daily earnings.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.accentGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${formatMoney(currentSalary)} salary available for today after deducting expenses.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final bool isLocked;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.isLocked,
    required this.onDelete,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'transport':
        return Icons.directions_bus_outlined;
      case 'spoilage':
        return Icons.delete_outline;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpoilage = expense.type == 'spoilage';

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
                color: isSpoilage
                    ? AppTheme.accentRed.withValues(alpha: 0.1)
                    : AppTheme.primaryDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(expense.type),
                color: isSpoilage ? AppTheme.accentRed : AppTheme.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        expense.type.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isSpoilage
                              ? AppTheme.accentRed
                              : AppTheme.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        formatMoney(expense.amountCentavos),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (isSpoilage && expense.grams != null) ...[
                    Text(
                      '${Weight.fromGrams(expense.grams!).formatKg()} spoiled'
                      '${expense.capitalPerKgCentavos != null ? ' @ ${formatMoney(expense.capitalPerKgCentavos!)}/kg cost' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      expense.note!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              tooltip: 'Delete Expense',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
