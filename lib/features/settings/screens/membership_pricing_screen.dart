import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student.dart';
import '../controllers/pricing_controller.dart';
import '../models/pricing_settings.dart';

class MembershipPricingScreen extends ConsumerStatefulWidget {
  const MembershipPricingScreen({super.key});

  @override
  ConsumerState<MembershipPricingScreen> createState() =>
      _MembershipPricingScreenState();
}

class _MembershipPricingScreenState
    extends ConsumerState<MembershipPricingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pricing = ref.watch(pricingProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Membership & Pricing',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
        children: [
          // Header Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E2438), const Color(0xFF161A29)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              ),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E3752)
                    : const Color(0xFFC7D2FE),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Rate Configuration',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Customize monthly, quarterly & annual rates with promotional badges.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Custom Segmented Pill Tab Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF191D2C)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2F45)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Full Time (24 Hours)'),
                Tab(text: 'Half Time (12 Hours)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Contents
          SizedBox(
            height: 620,
            child: TabBarView(
              controller: _tabController,
              children: [
                _PlanEditorGroup(
                  membership: MembershipType.fullTime,
                  pricing: pricing.fullTime,
                ),
                _PlanEditorGroup(
                  membership: MembershipType.halfTime,
                  pricing: pricing.halfTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanEditorGroup extends ConsumerWidget {
  final MembershipType membership;
  final PlanPricing pricing;

  const _PlanEditorGroup({
    required this.membership,
    required this.pricing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final periods = [
      (MembershipPeriod.monthly, Icons.calendar_view_month_rounded),
      (MembershipPeriod.quarterly, Icons.grid_view_rounded),
      (MembershipPeriod.halfYearly, Icons.date_range_rounded),
      (MembershipPeriod.annual, Icons.workspace_premium_rounded),
    ];

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final item in periods) ...[
          _PricingCard(
            period: item.$1,
            icon: item.$2,
            price: pricing.priceFor(item.$1),
            badge: pricing.badgeFor(item.$1),
            isDark: isDark,
            onPriceChanged: (val) {
              final amount = double.tryParse(val) ?? 0;
              ref
                  .read(pricingProvider.notifier)
                  .update(membership, item.$1, amount);
            },
            onBadgeChanged: (val) {
              ref
                  .read(pricingProvider.notifier)
                  .updateBadge(membership, item.$1, val);
            },
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final MembershipPeriod period;
  final IconData icon;
  final double price;
  final String badge;
  final bool isDark;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onBadgeChanged;

  const _PricingCard({
    required this.period,
    required this.icon,
    required this.price,
    required this.badge,
    required this.isDark,
    required this.onPriceChanged,
    required this.onBadgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C2B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF1E2238).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${period.label} Plan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    period.duration,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: TextFormField(
                  initialValue: price.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price Amount',
                    prefixText: '₹  ',
                    prefixStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF131724)
                        : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF242A3E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                  onChanged: onPriceChanged,
                ),
              ),
              if (period != MembershipPeriod.monthly) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    initialValue: badge,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Promo Badge Tag',
                      hintText: 'e.g. Popular',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF131724)
                          : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF242A3E)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.8,
                        ),
                      ),
                    ),
                    onChanged: onBadgeChanged,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
