import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/payment_confirmation_slider.dart';

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
            const Icon(Icons.arrow_forward, color: Colors.black38),
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
  const RenewalPaymentCard({super.key, required this.amount});
  @override
  Widget build(BuildContext context) => _Surface(
    child: Column(
      children: [
        Text(
          money(amount),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
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
        const Text(
          AppConstants.upiId,
          style: TextStyle(fontSize: 10, color: Color(0xFF858B9C)),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
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

class _Data extends StatelessWidget {
  final String label, value;
  final bool end;
  const _Data(this.label, this.value, {this.end = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.black45)),
      Text(
        value,
        textAlign: end ? TextAlign.right : TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ],
  );
}
