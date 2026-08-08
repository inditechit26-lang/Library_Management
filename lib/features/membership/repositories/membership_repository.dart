import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subscription_model.dart';

class MembershipRepository {
  MembershipRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<SubscriptionModel?> watchSubscription(String uid) {
    return _user(uid).snapshots().asyncMap((snapshot) async {
      final raw = snapshot.data()?['subscription'];
      if (raw is! Map) {
        await createTrialIfMissing(uid);
        return null;
      }
      final data = Map<String, dynamic>.from(raw);
      final model = SubscriptionModel.fromMap(data);
      if (model.effectiveStatus == MembershipStatus.expired &&
          model.status != MembershipStatus.expired) {
        await _user(uid).update({
          'subscription.status': 'Expired',
          'subscription.updatedAt': FieldValue.serverTimestamp(),
        });
        return SubscriptionModel.fromMap({...data, 'status': 'Expired'});
      }
      return model;
    });
  }

  Future<void> createTrialIfMissing(String uid) async {
    final reference = _user(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.data()?['subscription'] is Map) return;
      final start = DateTime.now();
      transaction.update(reference, {
        'subscription': {
          'status': 'Trial',
          'plan': 'Trial',
          'trialStartedAt': Timestamp.fromDate(start),
          'trialEndsAt': Timestamp.fromDate(start.add(const Duration(days: 7))),
          'membershipStartedAt': null,
          'membershipEndsAt': null,
          'activationCode': null,
          'activated': false,
          'activationDate': null,
          'ownerName': '',
          'libraryName': '',
          'mobile': '',
          'city': '',
          'seatCapacity': null,
          'onboardingCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
    });
  }

  Future<void> saveTrialProfile({
    required String uid,
    required String ownerName,
    required String libraryName,
    required String mobile,
    required String city,
    required int? seatCapacity,
  }) {
    return _user(uid).update({
      'subscription.ownerName': ownerName.trim(),
      'subscription.libraryName': libraryName.trim(),
      'subscription.mobile': mobile.trim(),
      'subscription.city': city.trim(),
      'subscription.seatCapacity': seatCapacity,
      'subscription.onboardingCompleted': true,
      'subscription.updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
