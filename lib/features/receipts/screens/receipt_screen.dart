import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key});
  @override
  ConsumerState<ReceiptScreen> createState() => _State();
}

class _State extends ConsumerState<ReceiptScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final students = ref
        .watch(studentsProvider)
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        SizedBox(
          height: 86,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _Summary(
                'TOTAL COLLECTED',
                '₹86,200',
                '12.5%',
                Icons.currency_rupee,
                Color(0xFF24926B),
                Color(0xFFE9F7F1),
              ),
              _Summary(
                'PENDING AMOUNT',
                '₹23,800',
                '12 students',
                Icons.schedule,
                Color(0xFFC6812C),
                Color(0xFFFFF1E2),
              ),
              _Summary(
                'THIS MONTH',
                '47 payments',
                '78% collected',
                Icons.calendar_month_outlined,
                Color(0xFF5B55C9),
                Color(0xFFF0EFFF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 54,
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9297A7)),
              hintText: context.tr('Search student...'),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...students.map(
          (student) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FeeCard(
              student: student,
              onPaid: () =>
                  ref.read(studentsProvider.notifier).markPaid(student),
            ),
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final String label, value, note;
  final IconData icon;
  final Color color, bg;
  const _Summary(
    this.label,
    this.value,
    this.note,
    this.icon,
    this.color,
    this.bg,
  );
  @override
  Widget build(BuildContext context) => Container(
    width: 235,
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: const Color(0xFFE4E7EF)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 8, color: Color(0xFF999EAC)),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(note, style: TextStyle(fontSize: 8, color: color)),
          ],
        ),
      ],
    ),
  );
}

class _FeeCard extends StatelessWidget {
  final Student student;
  final VoidCallback onPaid;
  const _FeeCard({required this.student, required this.onPaid});
  @override
  Widget build(BuildContext context) {
    final paid = student.payment == PaymentStatus.paid,
        overdue = student.payment == PaymentStatus.expired;
    final color = paid
        ? const Color(0xFF23936B)
        : overdue
        ? const Color(0xFFD3545D)
        : const Color(0xFFC47D25);
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFE4E7EF)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE8FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF625CA6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                'Fee: ${money(student.fee)}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF8F94A3)),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: color),
                    const SizedBox(width: 6),
                    Text(
                      paid
                          ? 'Paid'
                          : overdue
                          ? 'Overdue'
                          : 'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              paid
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check, size: 14),
                      label: Text(context.tr('Paid')),
                    )
                  : FilledButton(
                      onPressed: onPaid,
                      child: Text(context.tr('Mark paid')),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
