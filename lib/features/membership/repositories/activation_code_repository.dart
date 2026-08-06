import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activation_code_model.dart';

enum ActivationFailure { invalid, alreadyUsed, suspended }

class ActivationException implements Exception {
  const ActivationException(this.failure);
  final ActivationFailure failure;
}

class ActivationCodeRepository {
  ActivationCodeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ActivationCodeModel> activate({
    required String code,
    required String uid,
    required String email,
    required String libraryName,
  }) {
    final normalizedCode = code.trim().toUpperCase();
    final codeRef = _firestore
        .collection('activationCodes')
        .doc(normalizedCode);
    final userRef = _firestore.collection('users').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final codeSnapshot = await transaction.get(codeRef);
      if (!codeSnapshot.exists) {
        throw const ActivationException(ActivationFailure.invalid);
      }
      final activationCode = ActivationCodeModel.fromSnapshot(codeSnapshot);
      final status = activationCode.status.toLowerCase();
      if (status == 'used') {
        throw const ActivationException(ActivationFailure.alreadyUsed);
      }
      if (status != 'unused' && status != 'available') {
        throw const ActivationException(ActivationFailure.suspended);
      }

      final now = DateTime.now();
      final membershipEnd = now.add(
        Duration(days: activationCode.durationDays),
      );
      transaction.update(codeRef, {
        'status': 'used',
        'activatedAt': FieldValue.serverTimestamp(),
        'assignedToUid': uid,
        'assignedEmail': email,
        'assignedLibrary': libraryName,
      });
      transaction.update(userRef, {
        'subscription.status': 'Active',
        'subscription.plan': activationCode.plan,
        'subscription.activated': true,
        'subscription.activationCode': normalizedCode,
        'subscription.activationDate': FieldValue.serverTimestamp(),
        'subscription.membershipStartedAt': FieldValue.serverTimestamp(),
        'subscription.membershipEndsAt': Timestamp.fromDate(membershipEnd),
        'subscription.updatedAt': FieldValue.serverTimestamp(),
      });
      return activationCode;
    });
  }
}
