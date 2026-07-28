import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<BaseAuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final userProfileProvider = FutureProvider<AppUserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;

  final repository = ref.watch(authRepositoryProvider);
  return await repository.getUserProfile(user.uid);
});

final currentLibraryIdProvider = Provider<String?>((ref) {
  // Auth can complete before authStateChanges has caused the Firestore profile
  // provider to rebuild (especially during account creation). Prefer the profile
  // returned by the just-completed auth operation so user-scoped streams switch
  // libraries immediately.
  final authenticatedProfile = ref.watch(authControllerProvider).value;
  if (authenticatedProfile != null) {
    return authenticatedProfile.libraryId;
  }
  final userProfile = ref.watch(userProfileProvider);
  return userProfile.value?.libraryId;
});

class AuthNotifier extends AsyncNotifier<AppUserModel?> {
  @override
  FutureOr<AppUserModel?> build() {
    return null;
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(email, password),
    );
    if (!state.hasError) {
      ref.invalidate(userProfileProvider);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String libraryName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            email: email,
            password: password,
            displayName: displayName,
            libraryName: libraryName,
          ),
    );
    if (!state.hasError) {
      ref.invalidate(userProfileProvider);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
    if (!state.hasError && state.value != null) {
      ref.invalidate(userProfileProvider);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
      ref.invalidate(userProfileProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthNotifier, AppUserModel?>(AuthNotifier.new);
