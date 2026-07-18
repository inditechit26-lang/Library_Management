import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentProfileHeader extends StatelessWidget {
  final Student student;
  const StudentProfileHeader({super.key, required this.student});
  @override
  Widget build(BuildContext context) {
    final paid = student.payment == PaymentStatus.paid;
    return Column(
      children: [
        Hero(
          tag: 'student-${student.id}',
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: paid ? const Color(0xFF459A78) : const Color(0xFFC96A60),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFEDECF8),
              child: Text(
                student.initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF514BC0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          student.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          children: [
            _Pill(
              student.membership == MembershipType.fullTime
                  ? 'Full Time'
                  : 'Half Time',
            ),
            _Pill(
              student.membership == MembershipType.fullTime
                  ? 'Seat ${student.seat}'
                  : 'Flexible Seating',
            ),
            _Pill(student.payment.name),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF0EFFF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF514BC0),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
