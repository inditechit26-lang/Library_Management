import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/owner_profile_controller.dart';

class SubscriptionDetailsScreen extends ConsumerWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(ownerProfileProvider);
    final plan = profile.subscriptionPlan.isNotEmpty
        ? profile.subscriptionPlan
        : 'Trial';
    final isTrial = plan.toLowerCase() == 'trial';
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF332E78), Color(0xFF635BCE)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 18),
                Text(
                  isTrial ? 'StudyHub Trial' : 'StudyHub $plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTrial
                      ? 'Your workspace is currently on trial access.'
                      : 'Your library has an active membership.',
                  style: TextStyle(color: Colors.white.withValues(alpha: .8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DetailTile(Icons.workspace_premium_outlined, 'Current plan', plan),
          _DetailTile(
            Icons.verified_outlined,
            'Status',
            isTrial ? 'Trial access' : 'Active',
          ),
          _DetailTile(
            Icons.business_outlined,
            'Library',
            profile.libraryName.isNotEmpty
                ? profile.libraryName
                : 'Your library',
          ),
          const SizedBox(height: 14),
          Text(
            'Plan availability and renewal are managed by StudyHub support.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
