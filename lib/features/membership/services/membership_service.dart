import 'package:firebase_auth/firebase_auth.dart';

import '../models/activation_code_model.dart';
import '../repositories/activation_code_repository.dart';
import '../repositories/membership_repository.dart';

class MembershipService {
  const MembershipService({
    required MembershipRepository membershipRepository,
    required ActivationCodeRepository activationCodeRepository,
    required FirebaseAuth auth,
  }) : _membershipRepository = membershipRepository,
       _activationCodeRepository = activationCodeRepository,
       _auth = auth;

  final MembershipRepository _membershipRepository;
  final ActivationCodeRepository _activationCodeRepository;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Your session has expired.');
    return uid;
  }

  Future<void> startTrial({
    required String ownerName,
    required String libraryName,
    required String mobile,
    required String city,
    required int? seatCapacity,
  }) => _membershipRepository.saveTrialProfile(
    uid: _uid,
    ownerName: ownerName,
    libraryName: libraryName,
    mobile: mobile,
    city: city,
    seatCapacity: seatCapacity,
  );

  Future<ActivationCodeModel> activate({
    required String code,
    required String libraryName,
  }) {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Your session has expired.');
    return _activationCodeRepository.activate(
      code: code,
      uid: user.uid,
      email: user.email ?? '',
      libraryName: libraryName,
    );
  }
}
