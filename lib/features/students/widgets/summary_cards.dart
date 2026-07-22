import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentSummaryCards extends StatelessWidget {
  final List<Student> students;
  const StudentSummaryCards({super.key, required this.students});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Stat(
          label: 'Total\nStudents',
          value: '${students.length}',
          icon: Icons.people_outline_rounded,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Stat(
          label: 'Full\nTime',
          value:
              '${students.where((s) => s.membership == MembershipType.fullTime).length}',
          icon: Icons.workspace_premium_outlined,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Stat(
          label: 'Half\nTime',
          value:
              '${students.where((s) => s.membership == MembershipType.halfTime).length}',
          icon: Icons.schedule_rounded,
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    height: 112,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A262B44),
          blurRadius: 22,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF5B55CD), size: 18),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8,
            height: 1.2,
            color: Color(0xFF9297A7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
