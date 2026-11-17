import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Large, high-contrast numeric keypad optimized for single-handed market stall use.
///
/// Features:
/// - 3x4 grid with large touch targets (minimum 52dp height)
/// - Numbers 1-9, decimal point (.), 0, and backspace
/// - High contrast colors readable in direct sunlight
class StallKeypad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;
  final VoidCallback? onClear;

  const StallKeypad({
    super.key,
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
    this.onClear,
  });

  Widget _buildKey(
    BuildContext context, {
    required Widget child,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        child: Material(
          color: backgroundColor ?? AppTheme.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppTheme.borderSubtle, width: 0.8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 46,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitKey(BuildContext context, String digit) {
    return _buildKey(
      context,
      onTap: () => onDigit(digit),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1, 2, 3
        Row(
          children: [
            _buildDigitKey(context, '1'),
            _buildDigitKey(context, '2'),
            _buildDigitKey(context, '3'),
          ],
        ),
        // Row 2: 4, 5, 6
        Row(
          children: [
            _buildDigitKey(context, '4'),
            _buildDigitKey(context, '5'),
            _buildDigitKey(context, '6'),
          ],
        ),
        // Row 3: 7, 8, 9
        Row(
          children: [
            _buildDigitKey(context, '7'),
            _buildDigitKey(context, '8'),
            _buildDigitKey(context, '9'),
          ],
        ),
        // Row 4: ., 0, Backspace
        Row(
          children: [
            _buildKey(
              context,
              onTap: onDot,
              child: const Text(
                '•',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            _buildDigitKey(context, '0'),
            _buildKey(
              context,
              onTap: onBackspace,
              backgroundColor: Colors.grey.shade100,
              child: const Icon(
                Icons.backspace_outlined,
                size: 22,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
