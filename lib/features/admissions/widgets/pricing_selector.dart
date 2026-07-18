import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../settings/models/pricing_settings.dart';

class PricingSelector extends StatelessWidget {
  final MembershipPeriod? selected;
  final PlanPricing pricing;
  final ValueChanged<MembershipPeriod> onChanged;
  const PricingSelector({
    super.key,
    required this.selected,
    required this.pricing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Membership Duration',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 600
              ? (constraints.maxWidth - 20) / 3
              : (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MembershipPeriod.values.map((period) {
              final isSelected = selected == period;
              return SizedBox(
                width:
                    period == MembershipPeriod.custom &&
                        constraints.maxWidth < 600
                    ? constraints.maxWidth
                    : width,
                child: _PricingCard(
                  period: period,
                  price: period == MembershipPeriod.custom
                      ? null
                      : pricing.priceFor(period),
                  selected: isSelected,
                  badge: _badge(period, pricing),
                  onTap: () => onChanged(period),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );

  String? _badge(MembershipPeriod period, PlanPricing value) {
    final configured = value.badgeFor(period);
    if (configured.isNotEmpty) return configured;
    if (period == MembershipPeriod.quarterly) {
      final saving = value.monthly * 3 - value.quarterly;
      return saving > 0 ? 'Save ${money(saving)}' : null;
    }
    if (period == MembershipPeriod.halfYearly) {
      final saving = value.monthly * 6 - value.halfYearly;
      return saving > 0 ? 'Save ${money(saving)}' : null;
    }
    return null;
  }
}

class _PricingCard extends StatelessWidget {
  final MembershipPeriod period;
  final double? price;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;
  const _PricingCard({
    required this.period,
    required this.price,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  IconData get icon => switch (period) {
    MembershipPeriod.monthly => Icons.calendar_today_outlined,
    MembershipPeriod.quarterly => Icons.date_range_outlined,
    MembershipPeriod.halfYearly => Icons.calendar_month_outlined,
    MembershipPeriod.annual => Icons.emoji_events_outlined,
    MembershipPeriod.custom => Icons.auto_awesome_outlined,
  };

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: selected ? 1 : .98,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    child: Material(
      color: selected ? const Color(0xFFF5F4FF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 148,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6A63D7)
                  : const Color(0xFFE5E7EF),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x142F296F),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 19, color: const Color(0xFF5650C7)),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? const Icon(
                            Icons.check_circle,
                            key: ValueKey(true),
                            size: 19,
                            color: Color(0xFF5650C7),
                          )
                        : const SizedBox(key: ValueKey(false), height: 19),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                period.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                period.duration,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: Color(0xFF8D92A3)),
              ),
              if (badge != null) ...[
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F6F0),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 7,
                      color: Color(0xFF27805F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (price != null)
                Text(
                  money(price!),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
