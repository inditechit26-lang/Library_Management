import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pricing_controller.dart';

class MembershipPricingSettings extends ConsumerWidget {
  const MembershipPricingSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = ref.watch(pricingProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C2B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF1E2238).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership & Pricing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure rate plans for Full Time & Half Time',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/settings/pricing'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text(
                  'Manage',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Overview Cards Grid
          Row(
            children: [
              Expanded(
                child: _PlanOverviewTile(
                  title: 'Full Time',
                  rateText: '₹${pricing.fullTime.monthly.toInt()}/mo',
                  subtext: '24 Hours Plan',
                  badge: pricing.fullTime.badges.values.firstOrNull ?? 'Most Popular',
                  isDark: isDark,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlanOverviewTile(
                  title: 'Half Time',
                  rateText: '₹${pricing.halfTime.monthly.toInt()}/mo',
                  subtext: '12 Hours Plan',
                  badge: pricing.halfTime.badges.values.firstOrNull ?? 'Flexible',
                  isDark: isDark,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanOverviewTile extends StatelessWidget {
  final String title;
  final String rateText;
  final String subtext;
  final String badge;
  final bool isDark;
  final Color color;

  const _PlanOverviewTile({
    required this.title,
    required this.rateText,
    required this.subtext,
    required this.badge,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131724) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF242A3E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rateText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8C95A8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
