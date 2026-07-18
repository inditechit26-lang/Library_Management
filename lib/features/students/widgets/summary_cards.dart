import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentSummaryCards extends StatelessWidget {
  final List<Student> students;
  const StudentSummaryCards({super.key, required this.students});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 82,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _Stat(
          'Total\nStudents',
          '${students.length}',
          Icons.people_outline,
          '+8%',
        ),
        _Stat(
          'Full\nTime',
          '${students.where((s) => s.membership == MembershipType.fullTime).length}',
          Icons.auto_awesome,
          'Active',
        ),
        _Stat(
          'Half\nTime',
          '${students.where((s) => s.membership == MembershipType.halfTime).length}',
          Icons.schedule,
          'Flexible',
        ),
        _Stat(
          'Expiring',
          '${students.where((s) => s.payment == PaymentStatus.pending).length}',
          Icons.warning_amber,
          '7 days',
        ),
        _Stat(
          'Pending\nPayments',
          '${students.where((s) => s.payment != PaymentStatus.paid).length}',
          Icons.account_balance_wallet_outlined,
          'Action',
        ),
        const _Stat(
          'Monthly\nCollection',
          '₹86K',
          Icons.payments_outlined,
          '+12%',
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final String trend;
  const _Stat(this.label, this.value, this.icon, this.trend);
  @override
  Widget build(BuildContext context) => Container(
    width: 153,
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EE)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08262B44),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF5B55CD), size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                height: 1.3,
                color: Color(0xFF9297A7),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
