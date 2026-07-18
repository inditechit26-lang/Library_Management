import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class AdmissionPaymentSummary extends StatelessWidget {
  final String membership, joining, expiry;
  final double fee;
  const AdmissionPaymentSummary({
    super.key,
    required this.membership,
    required this.joining,
    required this.expiry,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EF)),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A20243B),
          blurRadius: 26,
          offset: Offset(0, 9),
        ),
      ],
    ),
    child: Column(
      children: [
        _Row('Membership Plan', membership),
        _Row('Monthly Fee', money(fee)),
        _Row('Joining Date', joining),
        _Row('Expiry Date', expiry, last: true),
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
    padding: EdgeInsets.only(bottom: last ? 0 : 13, top: 3),
    margin: EdgeInsets.only(bottom: last ? 0 : 10),
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
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
