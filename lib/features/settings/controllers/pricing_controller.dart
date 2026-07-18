import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student.dart';
import '../models/pricing_settings.dart';

class PricingController extends Notifier<PricingSettings> {
  @override
  PricingSettings build() => PricingSettings.defaults;

  void update(
    MembershipType membership,
    MembershipPeriod period,
    double value,
  ) {
    final current = state.forMembership(membership);
    final updated = switch (period) {
      MembershipPeriod.monthly => current.copyWith(monthly: value),
      MembershipPeriod.quarterly => current.copyWith(quarterly: value),
      MembershipPeriod.halfYearly => current.copyWith(halfYearly: value),
      MembershipPeriod.annual => current.copyWith(annual: value),
      MembershipPeriod.custom => current,
    };
    state = membership == MembershipType.fullTime
        ? state.copyWith(fullTime: updated)
        : state.copyWith(halfTime: updated);
  }

  void updateBadge(
    MembershipType membership,
    MembershipPeriod period,
    String value,
  ) {
    final current = state.forMembership(membership);
    final badges = Map<MembershipPeriod, String>.from(current.badges);
    value.trim().isEmpty
        ? badges.remove(period)
        : badges[period] = value.trim();
    final updated = current.copyWith(badges: badges);
    state = membership == MembershipType.fullTime
        ? state.copyWith(fullTime: updated)
        : state.copyWith(halfTime: updated);
  }
}

final pricingProvider = NotifierProvider<PricingController, PricingSettings>(
  PricingController.new,
);
