import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/subscription_model.dart';
import '../repositories/activation_code_repository.dart';
import '../repositories/membership_repository.dart';
import '../services/membership_service.dart';

final membershipRepositoryProvider = Provider<MembershipRepository>(
  (ref) => MembershipRepository(),
);

final activationCodeRepositoryProvider = Provider<ActivationCodeRepository>(
  (ref) => ActivationCodeRepository(),
);

final membershipServiceProvider = Provider<MembershipService>(
  (ref) => MembershipService(
    membershipRepository: ref.watch(membershipRepositoryProvider),
    activationCodeRepository: ref.watch(activationCodeRepositoryProvider),
    auth: FirebaseAuth.instance,
  ),
);

final membershipProvider = StreamProvider<SubscriptionModel?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(membershipRepositoryProvider).watchSubscription(uid);
});

class MembershipActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> startTrial({
    required String ownerName,
    required String libraryName,
    required String mobile,
    required String city,
    required int? seatCapacity,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(membershipServiceProvider)
          .startTrial(
            ownerName: ownerName,
            libraryName: libraryName,
            mobile: mobile,
            city: city,
            seatCapacity: seatCapacity,
          ),
    );
    return !state.hasError;
  }

  Future<bool> activate({
    required String code,
    required String libraryName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(membershipServiceProvider)
          .activate(code: code, libraryName: libraryName),
    );
    return !state.hasError;
  }
}

final membershipActionProvider =
    AsyncNotifierProvider<MembershipActionNotifier, void>(
      MembershipActionNotifier.new,
    );
