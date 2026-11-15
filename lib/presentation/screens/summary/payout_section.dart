import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/services/payout_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/payout_providers.dart';
import '../../theme/app_theme.dart';

/// Interactive payout settlement section implementing the 8-step formula.
class PayoutSection extends ConsumerStatefulWidget {
  final DailySummaryState summary;

  const PayoutSection({super.key, required this.summary});

  @override
  ConsumerState<PayoutSection> createState() => _PayoutSectionState();
}

class _PayoutSectionState extends ConsumerState<PayoutSection> {
  final _toParentsController = TextEditingController();
  final _salaryController = TextEditingController();

  int? _overrideToParentsCentavos;
  int? _overrideSalaryCentavos;

  @override
  void initState() {
    super.initState();
    _syncFields();
  }

  @override
  void didUpdateWidget(covariant PayoutSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.date != widget.summary.date ||
        oldWidget.summary.isLocked != widget.summary.isLocked) {
      _syncFields();
    }
  }

  void _syncFields() {
    final calc = widget.summary.calculation;
    final isLocked = widget.summary.isLocked;
    final payout = widget.summary.payout;

    if (isLocked && payout != null) {
      _overrideToParentsCentavos = payout.toParentsCentavos;
      _overrideSalaryCentavos = payout.salaryCentavos;
      _toParentsController.text = (payout.toParentsCentavos / 100)
          .toStringAsFixed(2);
      _salaryController.text = (payout.salaryCentavos / 100).toStringAsFixed(2);
    } else {
      _overrideToParentsCentavos = null;
      _overrideSalaryCentavos = null;
      _toParentsController.text = (calc.suggestedToParentsCentavos / 100)
          .toStringAsFixed(2);
      _salaryController.text = (calc.suggestedSalaryCentavos / 100)
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _toParentsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final isLocked = summary.isLocked;
    final baseCalc = summary.calculation;

    // Recalculate with live overrides if present
    final liveCalc = PayoutCalculator.calculate(
      salesCentavos: summary.totalChargedCentavos,
      capitalSoldCentavos: summary.capitalSoldCentavos,
      spoilageCentavos: summary.spoilageCentavos,
      otherExpensesCentavos: summary.otherExpensesCentavos,
      salaryMode: SalaryMode.percent, // or from settings
      salaryPercentBasisPoints: 3000,
      fixedDailySalaryCentavos: 0,
      actualToParentsCentavos: _overrideToParentsCentavos,
      actualSalaryCentavos: _overrideSalaryCentavos,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? AppTheme.warningAmber : Colors.grey.shade300,
          width: isLocked ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.payments_outlined, color: AppTheme.primaryDark),
                  SizedBox(width: 8),
                  Text(
                    'Daily Payout Settlement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 14, color: AppTheme.warningAmber),
                      SizedBox(width: 4),
                      Text(
                        'LOCKED',
                        style: TextStyle(
                          color: AppTheme.warningAmber,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Formula Steps 1 - 5
          _FormulaRow(
            step: '1',
            label: 'Sales (Charged)',
            value: formatMoney(summary.totalChargedCentavos),
          ),
          _FormulaRow(
            step: '2',
            label: 'Capital Sold (Produce Cost)',
            value: '-${formatMoney(summary.capitalSoldCentavos)}',
          ),
          _FormulaRow(
            step: '3',
            label: 'Gross Profit',
            value: formatMoney(liveCalc.grossProfitCentavos),
            isBold: true,
          ),
          _FormulaRow(
            step: '4a',
            label: 'Produce Spoilage Loss',
            value: '-${formatMoney(summary.spoilageCentavos)}',
          ),
          _FormulaRow(
            step: '4b',
            label: 'Other Operational Expenses',
            value: '-${formatMoney(summary.otherExpensesCentavos)}',
          ),
          const Divider(),
          _FormulaRow(
            step: '5',
            label: 'Net Profit',
            value: formatMoney(liveCalc.netProfitCentavos),
            isBold: true,
            fontSize: 17,
            valueColor: liveCalc.netProfitCentavos >= 0
                ? AppTheme.accentGreen
                : AppTheme.accentRed,
          ),
          const SizedBox(height: 12),

          // Step 6: To Parents (Capital Sold + Spoilage)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Step 6: Return to Parents',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Suggested: ${formatMoney(baseCalc.suggestedToParentsCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (!isLocked) ...[
                  TextField(
                    controller: _toParentsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Actual Amount to Return',
                      prefixText: 'P ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = parsePesoStringToCentavos(val);
                      setState(() {
                        _overrideToParentsCentavos = parsed;
                      });
                    },
                  ),
                  if (liveCalc.toParentsDiffCentavos != 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${liveCalc.toParentsDiffCentavos > 0 ? '+' : ''}${formatMoney(liveCalc.toParentsDiffCentavos)} from suggested',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: liveCalc.toParentsDiffCentavos > 0
                            ? AppTheme.accentGreen
                            : AppTheme.accentRed,
                      ),
                    ),
                  ],
                ] else ...[
                  Text(
                    formatMoney(liveCalc.actualToParentsCentavos),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Step 7: Salary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Step 7: Daily Salary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Suggested: ${formatMoney(baseCalc.suggestedSalaryCentavos)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (baseCalc.isSalaryCapped) ...[
                  const SizedBox(height: 2),
                  const Text(
                    '⚠️ Salary capped to available net profit',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningAmber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                if (!isLocked) ...[
                  TextField(
                    controller: _salaryController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Actual Salary Paid',
                      prefixText: 'P ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = parsePesoStringToCentavos(val);
                      setState(() {
                        _overrideSalaryCentavos = parsed;
                      });
                    },
                  ),
                  if (liveCalc.salaryDiffCentavos != 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${liveCalc.salaryDiffCentavos > 0 ? '+' : ''}${formatMoney(liveCalc.salaryDiffCentavos)} from suggested',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: liveCalc.salaryDiffCentavos > 0
                            ? AppTheme.accentGreen
                            : AppTheme.accentRed,
                      ),
                    ),
                  ],
                ] else ...[
                  Text(
                    formatMoney(liveCalc.actualSalaryCentavos),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Step 8: Reserve / Shortfall
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: liveCalc.hasShortfall
                  ? AppTheme.accentRed.withValues(alpha: 0.1)
                  : AppTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: liveCalc.hasShortfall
                    ? AppTheme.accentRed
                    : AppTheme.accentGreen,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveCalc.hasShortfall
                          ? 'RESERVE SHORTFALL'
                          : 'RESERVE ACCUMULATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: liveCalc.hasShortfall
                            ? AppTheme.accentRed
                            : AppTheme.accentGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      liveCalc.hasShortfall
                          ? 'Deficit covered by capital'
                          : 'Retained business cash',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatMoney(liveCalc.reserveCentavos),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: liveCalc.hasShortfall
                        ? AppTheme.accentRed
                        : AppTheme.accentGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Payout Actions: Mark as Paid Out / Reopen Day
          if (!isLocked) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.lock_outline),
              label: const Text(
                'Mark as Paid Out & Lock Day',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Lock Day Payout?'),
                    content: const Text(
                      'Marking this day as paid out locks all sales, expenses, and payout values for today.\n\n'
                      'You can reopen it anytime if you need to make adjustments.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Confirm & Lock'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(payoutRepositoryProvider)
                      .saveAndLockPayout(
                        date: summary.date,
                        toParentsCentavos: liveCalc.actualToParentsCentavos,
                        salaryCentavos: liveCalc.actualSalaryCentavos,
                        reserveCentavos: liveCalc.reserveCentavos,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Day payout locked successfully.'),
                      ),
                    );
                  }
                }
              },
            ),
          ] else ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningAmber,
                side: const BorderSide(
                  color: AppTheme.warningAmber,
                  width: 1.5,
                ),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.lock_open),
              label: const Text(
                'Reopen Day Payout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reopen Day Payout?'),
                    content: const Text(
                      'Reopening this day will allow modifying transactions, adding expenses, and recalculating payouts.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Reopen Day'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(payoutRepositoryProvider)
                      .unlockDay(summary.date);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Day payout unlocked.')),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  final String step;
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _FormulaRow({
    required this.step,
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 14,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$step.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ],
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
