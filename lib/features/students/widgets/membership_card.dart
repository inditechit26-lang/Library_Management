import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/premium_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/student.dart';
import 'package:intl/intl.dart';

class MembershipCard extends StatelessWidget {
  final Student student;
  final VoidCallback onRenew;
  final VoidCallback onSendReminder;
  final VoidCallback onReceipt;
  const MembershipCard({
    super.key,
    required this.student,
    required this.onRenew,
    required this.onSendReminder,
    required this.onReceipt,
  });
  int get daysRemaining {
    try {
      return DateFormat(
        'dd MMM yyyy',
      ).parse(student.expiry).difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) => PremiumCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: Theme.of(context).colorScheme.primary,
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
            _Value('DAYS REMAINING', '${daysRemaining.clamp(0, 9999)} days'),
            _Value('FEE', money(student.fee)),
          ],
        ),
        const SizedBox(height: 18),
        // `hasRenewedPlan` is only an in-memory legacy UI flag and is not
        // persisted with the student record. A successful admission payment
        // or renewal is represented by the paid status, so use that durable
        // value when deciding whether a receipt can be viewed.
        if (student.payment == PaymentStatus.paid)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onReceipt,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('View Payment Receipt (PDF)'),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRenew,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Renew Plan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSendReminder,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                  ),
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 17,
                    color: Colors.white,
                  ),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
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
