import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter/features/membership/models/subscription_model.dart';

void main() {
  Map<String, dynamic> subscription({
    required String status,
    required DateTime trialEnd,
    DateTime? membershipEnd,
    bool onboardingCompleted = true,
  }) => {
    'status': status,
    'plan': status == 'Active' ? 'Standard' : 'Trial',
    'activated': status == 'Active',
    'trialStartedAt': Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 1)),
    ),
    'trialEndsAt': Timestamp.fromDate(trialEnd),
    'membershipEndsAt': membershipEnd == null
        ? null
        : Timestamp.fromDate(membershipEnd),
    'ownerName': 'Owner',
    'libraryName': 'Study Library',
    'mobile': '9876543210',
    'onboardingCompleted': onboardingCompleted,
    'createdAt': Timestamp.now(),
  };

  test('completed valid trial can access the application', () {
    final model = SubscriptionModel.fromMap(
      subscription(
        status: 'Trial',
        trialEnd: DateTime.now().add(const Duration(days: 6)),
      ),
    );
    expect(model.effectiveStatus, MembershipStatus.trial);
    expect(model.canAccessApp, isTrue);
  });

  test('expired trial is locked', () {
    final model = SubscriptionModel.fromMap(
      subscription(
        status: 'Trial',
        trialEnd: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    );
    expect(model.effectiveStatus, MembershipStatus.expired);
    expect(model.canAccessApp, isFalse);
  });

  test('active membership uses membership expiry', () {
    final model = SubscriptionModel.fromMap(
      subscription(
        status: 'Active',
        trialEnd: DateTime.now().subtract(const Duration(days: 30)),
        membershipEnd: DateTime.now().add(const Duration(days: 365)),
        onboardingCompleted: false,
      ),
    );
    expect(model.effectiveStatus, MembershipStatus.active);
    expect(model.canAccessApp, isTrue);
  });
}
