import 'package:cloud_firestore/cloud_firestore.dart';

enum MembershipStatus { trial, active, expired, suspended }

class SubscriptionModel {
  const SubscriptionModel({
    required this.status,
    required this.plan,
    required this.activated,
    required this.trialStartedAt,
    required this.trialEndsAt,
    required this.createdAt,
    this.membershipStartedAt,
    this.membershipEndsAt,
    this.activationCode,
    this.activationDate,
    this.ownerName = '',
    this.libraryName = '',
    this.mobile = '',
    this.city = '',
    this.seatCapacity,
    this.onboardingCompleted = false,
  });

  final MembershipStatus status;
  final String plan;
  final bool activated;
  final DateTime trialStartedAt;
  final DateTime trialEndsAt;
  final DateTime? membershipStartedAt;
  final DateTime? membershipEndsAt;
  final String? activationCode;
  final DateTime? activationDate;
  final String ownerName;
  final String libraryName;
  final String mobile;
  final String city;
  final int? seatCapacity;
  final bool onboardingCompleted;
  final DateTime createdAt;

  factory SubscriptionModel.fromMap(Map<String, dynamic> data) {
    DateTime? date(String key) => (data[key] as Timestamp?)?.toDate();
    final now = DateTime.now();
    final rawStatus = (data['status'] as String? ?? 'Trial').toLowerCase();
    return SubscriptionModel(
      status: MembershipStatus.values.firstWhere(
        (item) => item.name == rawStatus,
        orElse: () => MembershipStatus.trial,
      ),
      plan: data['plan'] as String? ?? 'Trial',
      activated: data['activated'] as bool? ?? false,
      trialStartedAt: date('trialStartedAt') ?? now,
      trialEndsAt: date('trialEndsAt') ?? now,
      membershipStartedAt: date('membershipStartedAt'),
      membershipEndsAt: date('membershipEndsAt'),
      activationCode: data['activationCode'] as String?,
      activationDate: date('activationDate'),
      ownerName: data['ownerName'] as String? ?? '',
      libraryName: data['libraryName'] as String? ?? '',
      mobile: data['mobile'] as String? ?? '',
      city: data['city'] as String? ?? '',
      seatCapacity: (data['seatCapacity'] as num?)?.toInt(),
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      createdAt: date('createdAt') ?? now,
    );
  }

  bool get hasRequiredProfile =>
      ownerName.trim().isNotEmpty &&
      libraryName.trim().isNotEmpty &&
      mobile.trim().isNotEmpty;

  bool get trialExpired => !trialEndsAt.isAfter(DateTime.now());
  bool get membershipExpired =>
      membershipEndsAt == null || !membershipEndsAt!.isAfter(DateTime.now());

  MembershipStatus get effectiveStatus {
    if (status == MembershipStatus.suspended) return status;
    if (status == MembershipStatus.trial && trialExpired) {
      return MembershipStatus.expired;
    }
    if (status == MembershipStatus.active && membershipExpired) {
      return MembershipStatus.expired;
    }
    return status;
  }

  bool get canAccessApp =>
      effectiveStatus == MembershipStatus.active ||
      (effectiveStatus == MembershipStatus.trial &&
          onboardingCompleted &&
          hasRequiredProfile);

  DateTime? get currentPeriodEnd => status == MembershipStatus.active
      ? membershipEndsAt
      : status == MembershipStatus.trial
      ? trialEndsAt
      : membershipEndsAt ?? trialEndsAt;

  int get daysRemaining {
    final end = currentPeriodEnd;
    if (end == null || !end.isAfter(DateTime.now())) return 0;
    return (end.difference(DateTime.now()).inHours / 24).ceil();
  }
}
