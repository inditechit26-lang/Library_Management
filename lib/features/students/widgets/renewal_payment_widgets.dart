import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/payment_confirmation_slider.dart';
import '../models/student.dart';

class RenewalDateSummary extends StatelessWidget {
  final String current, expiry, plan;
  final double amount;
  const RenewalDateSummary({
    super.key,
    required this.current,
    required this.expiry,
    required this.plan,
    required this.amount,
  });
  @override
  Widget build(BuildContext context) => _Surface(
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _Data('CURRENT EXPIRY', current)),
            Icon(
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Expanded(child: _Data('NEW EXPIRY', expiry, end: true)),
          ],
        ),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(child: _Data('PLAN', plan)),
            _Data('TOTAL', money(amount), end: true),
          ],
        ),
      ],
    ),
  );
}

class RenewalPaymentCard extends StatelessWidget {
  final double amount;
  final PaymentMode mode;
  final ValueChanged<PaymentMode> onModeChanged;

  const RenewalPaymentCard({
    super.key,
    required this.amount,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCash = mode == PaymentMode.cash;

    return _Surface(
      child: Column(
        children: [
          Text(
            money(amount),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (!isCash) ...[
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFEEEFF4)),
              ),
              child: QrImageView(
                data:
                    'upi://pay?pa=${AppConstants.upiId}&pn=${Uri.encodeComponent(AppConstants.libraryName)}&am=$amount&cu=INR',
                size: 152,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              AppConstants.upiId,
              style: TextStyle(
                fontSize: 10,
                color: colors.onSurfaceVariant,
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.payments_rounded, size: 36, color: colors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cash Payment Selected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Collect ${money(amount)} in cash from student.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ModeChip(
                  label: 'UPI / QR',
                  icon: Icons.qr_code_2_rounded,
                  selected: mode == PaymentMode.upi,
                  onTap: () => onModeChanged(PaymentMode.upi),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeChip(
                  label: 'Cash Payment',
                  icon: Icons.payments_outlined,
                  selected: mode == PaymentMode.cash,
                  onTap: () => onModeChanged(PaymentMode.cash),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RenewalSlideConfirm extends StatelessWidget {
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  const RenewalSlideConfirm({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => PaymentConfirmationSlider(
    enabled: enabled,
    onConfirmed: () => onChanged(1),
  );
}

class _Surface extends StatelessWidget {
  final Widget child;
  const _Surface({required this.child});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0920243B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Data extends StatelessWidget {
  final String label, value;
  final bool end;
  const _Data(this.label, this.value, {this.end = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      Text(
        value,
        textAlign: end ? TextAlign.right : TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ],
  );
}
