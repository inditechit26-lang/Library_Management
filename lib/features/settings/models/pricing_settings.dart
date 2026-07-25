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
  final PlanPricing fullTimeAc, halfTimeAc;
  final PlanPricing fullTimeNonAc, halfTimeNonAc;
  final List<String> halfTimeShifts;

  const PricingSettings({
    required this.fullTimeAc,
    required this.halfTimeAc,
    required this.fullTimeNonAc,
    required this.halfTimeNonAc,
    this.halfTimeShifts = const [
      'Morning Shift (06:00 AM - 02:00 PM)',
      'Evening Shift (02:00 PM - 10:00 PM)',
    ],
  });

  PlanPricing get fullTime => fullTimeAc;
  PlanPricing get halfTime => halfTimeAc;

  PlanPricing forMembership(MembershipType membership) =>
      forMembershipAndCategory(membership, SeatCategory.ac);

  PlanPricing forMembershipAndCategory(
    MembershipType membership,
    SeatCategory category,
  ) {
    if (category == SeatCategory.ac) {
      return membership == MembershipType.fullTime ? fullTimeAc : halfTimeAc;
    } else {
      return membership == MembershipType.fullTime
          ? fullTimeNonAc
          : halfTimeNonAc;
    }
  }

  PricingSettings copyWith({
    PlanPricing? fullTimeAc,
    PlanPricing? halfTimeAc,
    PlanPricing? fullTimeNonAc,
    PlanPricing? halfTimeNonAc,
    PlanPricing? fullTime,
    PlanPricing? halfTime,
    List<String>? halfTimeShifts,
  }) => PricingSettings(
    fullTimeAc: fullTimeAc ?? fullTime ?? this.fullTimeAc,
    halfTimeAc: halfTimeAc ?? halfTime ?? this.halfTimeAc,
    fullTimeNonAc: fullTimeNonAc ?? this.fullTimeNonAc,
    halfTimeNonAc: halfTimeNonAc ?? this.halfTimeNonAc,
    halfTimeShifts: halfTimeShifts ?? this.halfTimeShifts,
  );

  static const defaults = PricingSettings(
    fullTimeAc: PlanPricing(
      monthly: 1800,
      quarterly: 5200,
      halfYearly: 10000,
      annual: 19000,
      badges: {
        MembershipPeriod.quarterly: 'Most Popular',
        MembershipPeriod.annual: 'Best Value',
      },
    ),
    halfTimeAc: PlanPricing(
      monthly: 1200,
      quarterly: 3400,
      halfYearly: 6500,
      annual: 12000,
      badges: {
        MembershipPeriod.quarterly: 'Most Popular',
        MembershipPeriod.annual: 'Best Value',
      },
    ),
    fullTimeNonAc: PlanPricing(
      monthly: 1400,
      quarterly: 4000,
      halfYearly: 7800,
      annual: 15000,
      badges: {
        MembershipPeriod.quarterly: 'Most Popular',
        MembershipPeriod.annual: 'Best Value',
      },
    ),
    halfTimeNonAc: PlanPricing(
      monthly: 900,
      quarterly: 2600,
      halfYearly: 5000,
      annual: 9500,
      badges: {
        MembershipPeriod.quarterly: 'Most Popular',
        MembershipPeriod.annual: 'Best Value',
      },
    ),
    halfTimeShifts: [
      'Morning Shift (06:00 AM - 02:00 PM)',
      'Evening Shift (02:00 PM - 10:00 PM)',
    ],
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
