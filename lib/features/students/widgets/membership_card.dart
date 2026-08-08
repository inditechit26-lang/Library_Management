import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/utils/formatters.dart';
import '../models/student.dart';

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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final remainingDays = daysRemaining;
    final isExpired = remainingDays < 0;
    final isDueSoon = !isExpired && remainingDays <= 7;
    final statusColor = isExpired
        ? colors.error
        : isDueSoon
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);
    final statusLabel = isExpired
        ? 'EXPIRED'
        : isDueSoon
        ? 'RENEWS SOON'
        : 'ACTIVE MEMBERSHIP';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.secondary, .45)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('Membership'),
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            student.membership == MembershipType.fullTime
                ? 'Full Time Plan'
                : 'Half Time Plan',
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isExpired
                ? 'Membership expired ${-remainingDays} day${remainingDays == -1 ? '' : 's'} ago'
                : '$remainingDays day${remainingDays == 1 ? '' : 's'} remaining',
            style: TextStyle(color: colors.onPrimary.withValues(alpha: .82)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Value(
                    'EXPIRY DATE',
                    student.expiry,
                    foreground: colors.onPrimary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: colors.onPrimary.withValues(alpha: .24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Value(
                    'PLAN FEE',
                    money(student.fee),
                    foreground: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (student.payment == PaymentStatus.paid)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onReceipt,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.onPrimary,
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('View Payment Receipt'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRenew,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onPrimary,
                      side: BorderSide(
                        color: colors.onPrimary.withValues(alpha: .62),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Renew'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSendReminder,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}

class _Value extends StatelessWidget {
  final String label;
  final String value;
  final Color foreground;

  const _Value(this.label, this.value, {required this.foreground});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: foreground.withValues(alpha: .72),
          letterSpacing: .6,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .2),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .72)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: .45,
      ),
    ),
  );
}
