import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/screens/subscription_gate_screen.dart';
import '../../membership/models/subscription_model.dart';
import '../../membership/providers/membership_provider.dart';
import '../../update/providers/update_provider.dart';

class MembershipCard extends ConsumerWidget {
  const MembershipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(membershipProvider).value;
    if (value == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final status = value.effectiveStatus;
    final version = ref.watch(appUpdateProvider).currentVersion;
    final date = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 2,
      shadowColor: colors.shadow.withValues(alpha: .12),
      color: colors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.status == MembershipStatus.active
                            ? '${value.plan} Membership'
                            : 'StudyHall Pro',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value.libraryName.isEmpty
                            ? 'Membership & licensing'
                            : value.libraryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.outlineVariant),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              runSpacing: 14,
              children: [
                _Detail(
                  'Owner',
                  value.ownerName.isEmpty ? '—' : value.ownerName,
                ),
                _Detail(
                  'Activated',
                  value.activationDate == null
                      ? 'Not activated'
                      : date.format(value.activationDate!),
                ),
                _Detail(
                  'Expiry',
                  value.currentPeriodEnd == null
                      ? '—'
                      : date.format(value.currentPeriodEnd!),
                ),
                _Detail('Days Remaining', '${value.daysRemaining} days'),
                _Detail(
                  'Activation Code',
                  value.activationCode ?? 'Not activated',
                ),
                _Detail('Current Version', version),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  useSafeArea: false,
                  builder: (_) => SubscriptionGateScreen(
                    subscription: value,
                    requiredGate: false,
                    openPurchase: true,
                  ),
                ),
                icon: const Icon(Icons.manage_accounts_outlined),
                label: Text(
                  status == MembershipStatus.active
                      ? 'Manage Membership'
                      : 'View Membership Options',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 142,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final MembershipStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      MembershipStatus.trial => ('TRIAL', colors.tertiary),
      MembershipStatus.active => ('ACTIVE', const Color(0xFF23855B)),
      MembershipStatus.expired => ('EXPIRED', colors.error),
      MembershipStatus.suspended => ('SUSPENDED', colors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }
}
