import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class MembershipSummary extends StatelessWidget {
  final String plan, membership, joining, expiry, duration, seat;
  final double amount;
  const MembershipSummary({
    super.key,
    required this.plan,
    required this.membership,
    required this.joining,
    required this.expiry,
    required this.duration,
    required this.seat,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0x0B20243B),
              blurRadius: 28,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 9),
                const Text(
                  'Membership Summary',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const Divider(height: 26),
            _AnimatedRow('Plan', plan),
            _AnimatedRow('Membership', membership),
            _AnimatedRow('Joining', joining),
            _AnimatedRow('Expiry', expiry),
            _AnimatedRow('Duration', duration),
            _AnimatedRow('Seat', seat),
            const Divider(height: 22),
            _AnimatedRow('Total Amount', money(amount), strong: true),
          ],
        ),
      ),
    );
  }
}

class _AnimatedRow extends StatelessWidget {
  final String label, value;
  final bool strong;
  const _AnimatedRow(this.label, this.value, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              value.isEmpty ? '—' : value,
              key: ValueKey(value),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: strong ? 14 : 10,
                fontWeight: FontWeight.w800,
                color: strong ? colors.primary : colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
