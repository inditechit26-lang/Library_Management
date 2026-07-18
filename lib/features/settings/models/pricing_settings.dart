import '../../students/models/student.dart';

enum MembershipPeriod { monthly, quarterly, halfYearly, annual, custom }

class PlanPricing {
  final double monthly, quarterly, halfYearly, annual;
  final Map<MembershipPeriod, String> badges;
  const PlanPricing({
    required this.monthly,
    required this.quarterly,
    required this.halfYearly,
    required this.annual,
    this.badges = const {},
  });

  double priceFor(MembershipPeriod period) => switch (period) {
    MembershipPeriod.monthly => monthly,
    MembershipPeriod.quarterly => quarterly,
    MembershipPeriod.halfYearly => halfYearly,
    MembershipPeriod.annual => annual,
    MembershipPeriod.custom => 0,
  };

  String badgeFor(MembershipPeriod period) => badges[period] ?? '';

  PlanPricing copyWith({
    double? monthly,
    double? quarterly,
    double? halfYearly,
    double? annual,
    Map<MembershipPeriod, String>? badges,
  }) => PlanPricing(
    monthly: monthly ?? this.monthly,
    quarterly: quarterly ?? this.quarterly,
    halfYearly: halfYearly ?? this.halfYearly,
    annual: annual ?? this.annual,
    badges: badges ?? this.badges,
  );
}

class PricingSettings {
  final PlanPricing fullTime, halfTime;
  const PricingSettings({required this.fullTime, required this.halfTime});

  PlanPricing forMembership(MembershipType membership) =>
      membership == MembershipType.fullTime ? fullTime : halfTime;

  PricingSettings copyWith({PlanPricing? fullTime, PlanPricing? halfTime}) =>
      PricingSettings(
        fullTime: fullTime ?? this.fullTime,
        halfTime: halfTime ?? this.halfTime,
      );

  static const defaults = PricingSettings(
    fullTime: PlanPricing(
      monthly: 1800,
      quarterly: 5200,
      halfYearly: 10000,
      annual: 19000,
      badges: {
        MembershipPeriod.quarterly: 'Most Popular',
        MembershipPeriod.annual: 'Best Value',
      },
    ),
    halfTime: PlanPricing(
      monthly: 1200,
      quarterly: 3400,
      halfYearly: 6500,
      annual: 12000,
      badges: {
        MembershipPeriod.quarterly: 'Most Popular',
        MembershipPeriod.annual: 'Best Value',
      },
    ),
  );
}

extension MembershipPeriodDetails on MembershipPeriod {
  String get label => switch (this) {
    MembershipPeriod.monthly => 'Monthly',
    MembershipPeriod.quarterly => 'Quarterly',
    MembershipPeriod.halfYearly => 'Half-Yearly',
    MembershipPeriod.annual => 'Annual',
    MembershipPeriod.custom => 'Custom',
  };
  int get months => switch (this) {
    MembershipPeriod.monthly => 1,
    MembershipPeriod.quarterly => 3,
    MembershipPeriod.halfYearly => 6,
    MembershipPeriod.annual => 12,
    MembershipPeriod.custom => 0,
  };
  String get duration => this == MembershipPeriod.custom
      ? 'Choose your own duration'
      : '$months ${months == 1 ? 'Month' : 'Months'}';
}
