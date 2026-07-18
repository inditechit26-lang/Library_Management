import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/premium_card.dart';
import '../models/student.dart';

class MembershipCard extends StatelessWidget {
  final Student student;
  final VoidCallback onRenew;
  const MembershipCard({
    super.key,
    required this.student,
    required this.onRenew,
  });
  @override
  Widget build(BuildContext context) => PremiumCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFF514BC0),
            ),
            const SizedBox(width: 9),
            Text(
              context.tr('Membership'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Value(
              'CURRENT PLAN',
              student.membership == MembershipType.fullTime
                  ? 'Full Time'
                  : 'Half Time',
            ),
            _Value('CURRENT EXPIRY', student.expiry),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _Value('DAYS REMAINING', '30 days'),
            _Value('FEE', money(student.fee)),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onRenew,
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('Renew Membership')),
          ),
        ),
      ],
    ),
  );
}

class _Value extends StatelessWidget {
  final String label, value;
  const _Value(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: .6,
        ),
      ),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}
