import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/premium_card.dart';
import '../models/student.dart';

class StudentInformationCard extends StatelessWidget {
  final Student student;
  const StudentInformationCard({super.key, required this.student});
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Personal Information',
    icon: Icons.person_outline,
    children: [
      _Row('Student Name', student.name),
      _Row('Phone Number', student.phone),
      _Row('Joining Date', student.joined),
      _Row(
        'Membership Type',
        student.membership == MembershipType.fullTime
            ? 'Full Time'
            : 'Half Time',
      ),
      _Row(
        'Seat Number',
        student.membership == MembershipType.fullTime
            ? student.seat
            : 'Flexible Seating',
      ),
      const _Row('Notes', 'Prefers a quiet corner seat.'),
    ],
  );
}

class PaymentInformationCard extends StatelessWidget {
  final Student student;
  final VoidCallback onReceipt;
  const PaymentInformationCard({
    super.key,
    required this.student,
    required this.onReceipt,
  });
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Payment Information',
    icon: Icons.account_balance_wallet_outlined,
    children: [
      _Row('Monthly Fee', money(student.fee)),
      const _Row('Last Payment', '05 Jul 2026'),
      _Row('Current Expiry', student.expiry),
      _Row('Next Renewal', student.expiry),
      _Row('Payment Status', student.payment.name),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Receipt History',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: TextButton(
          onPressed: onReceipt,
          child: const Text('View receipts'),
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
            Icon(icon, color: const Color(0xFF514BC0)),
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
            style: const TextStyle(fontSize: 12, color: Colors.black54),
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
