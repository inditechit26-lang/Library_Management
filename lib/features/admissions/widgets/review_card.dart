import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class AdmissionReviewCard extends StatelessWidget {
  final String student, membership, seat, joining, expiry, payment;
  final double fee;
  const AdmissionReviewCard({
    super.key,
    required this.student,
    required this.membership,
    required this.seat,
    required this.fee,
    required this.joining,
    required this.expiry,
    required this.payment,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C20243B),
          blurRadius: 30,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        _Row('Student', student),
        _Row('Membership', membership),
        _Row('Seat', seat),
        _Row('Fee', money(fee)),
        _Row('Joining Date', joining),
        _Row('Expiry Date', expiry),
        _Row('Payment Status', payment, last: true),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool last;
  const _Row(this.label, this.value, {this.last = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFEEEFF4))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF858B9C)),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}
