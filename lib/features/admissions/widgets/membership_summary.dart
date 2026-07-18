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
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFD),
        border: Border.all(color: const Color(0xFFE5E7EF)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B20243B),
            blurRadius: 28,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF5650C7),
                size: 20,
              ),
              SizedBox(width: 9),
              Text(
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

class _AnimatedRow extends StatelessWidget {
  final String label, value;
  final bool strong;
  const _AnimatedRow(this.label, this.value, {this.strong = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF858B9C)),
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
              color: strong ? const Color(0xFF5650C7) : const Color(0xFF25283A),
            ),
          ),
        ),
      ],
    ),
  );
}
