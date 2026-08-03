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
    this.halfTimeShifts = const [],
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
    fullTimeAc: PlanPricing(monthly: 0, quarterly: 0, halfYearly: 0, annual: 0),
    halfTimeAc: PlanPricing(monthly: 0, quarterly: 0, halfYearly: 0, annual: 0),
    fullTimeNonAc: PlanPricing(
      monthly: 0,
      quarterly: 0,
      halfYearly: 0,
      annual: 0,
    ),
    halfTimeNonAc: PlanPricing(
      monthly: 0,
      quarterly: 0,
      halfYearly: 0,
      annual: 0,
    ),
    halfTimeShifts: [],
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
