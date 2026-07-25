import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/premium_card.dart';
import '../models/student.dart';

class StudentInformationCard extends StatelessWidget {
  final Student student;
  const StudentInformationCard({super.key, required this.student});
  @override
  Widget build(BuildContext context) => _Section(
    title: context.tr('Personal Information'),
    icon: Icons.person_outline,
    children: [
      _Row('Student Name', student.name),
      _Row('Phone Number', student.phone),
      if (student.emergencyContact.isNotEmpty)
        _Row('Emergency Contact', student.emergencyContact),
      _Row('Joining Date', student.joined),
      _Row(
        'Membership Type',
        '${student.membership == MembershipType.fullTime ? 'Full Time' : 'Half Time'} (${student.category.shortLabel})',
      ),
      _Row('Hall Section', student.category.label),
      if (student.membership == MembershipType.fullTime) ...[
        _Row('Seat Number', student.seat),
      ] else ...[
        const _Row('Seat Number', 'Flexible Seating'),
        _Row(
          'Shift Time',
          student.halfTimeShiftTime ?? 'Flexible Shift',
        ),
      ],
      _Row('Notes', student.notes.isEmpty ? '—' : student.notes),
    ],
  );
}

class PaymentInformationCard extends StatelessWidget {
  final Student student;
  final VoidCallback onPaymentHistory;
  const PaymentInformationCard({
    super.key,
    required this.student,
    required this.onPaymentHistory,
  });
  @override
  Widget build(BuildContext context) => _Section(
    title: context.tr('Payment Information'),
    icon: Icons.account_balance_wallet_outlined,
    children: [
      _Row('Monthly Fee', money(student.fee)),
      const _Row('Last Payment', '05 Jul 2026'),
      _Row('Current Expiry', student.expiry),
      _Row('Next Renewal', student.expiry),
      _Row('Payment Status', student.payment.name),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Payment History',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          'Review monthly payments and their status.',
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        trailing: TextButton.icon(
          onPressed: onPaymentHistory,
          icon: const Icon(Icons.history_rounded, size: 17),
          label: const Text('View history'),
        ),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => PremiumCard(
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 9),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const Divider(height: 24),
        ...children,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
