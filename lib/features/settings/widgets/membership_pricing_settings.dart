import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student.dart';
import '../controllers/pricing_controller.dart';
import '../models/pricing_settings.dart';

class MembershipPricingSettings extends ConsumerWidget {
  const MembershipPricingSettings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = ref.watch(pricingProvider);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0920243B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: Color(0xFF5650C7)),
              SizedBox(width: 10),
              Text(
                'Membership Pricing',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _PricingGroup(
            title: 'Full Time',
            membership: MembershipType.fullTime,
            pricing: pricing.fullTime,
          ),
          const Divider(height: 30),
          _PricingGroup(
            title: 'Half Time',
            membership: MembershipType.halfTime,
            pricing: pricing.halfTime,
          ),
        ],
      ),
    );
  }
}

class _PricingGroup extends ConsumerWidget {
  final String title;
  final MembershipType membership;
  final PlanPricing pricing;
  const _PricingGroup({
    required this.title,
    required this.membership,
    required this.pricing,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      ...MembershipPeriod.values
          .where((period) => period != MembershipPeriod.custom)
          .map(
            (period) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                initialValue: pricing.priceFor(period).toStringAsFixed(0),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: period.label,
                  prefixText: '₹  ',
                ),
                onChanged: (value) => ref
                    .read(pricingProvider.notifier)
                    .update(membership, period, double.tryParse(value) ?? 0),
              ),
            ),
          ),
      const SizedBox(height: 2),
      ...[
        MembershipPeriod.quarterly,
        MembershipPeriod.halfYearly,
        MembershipPeriod.annual,
      ].map(
        (period) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            initialValue: pricing.badgeFor(period),
            decoration: InputDecoration(labelText: '${period.label} Badge'),
            onChanged: (value) => ref
                .read(pricingProvider.notifier)
                .updateBadge(membership, period, value),
          ),
        ),
      ),
    ],
  );
}
