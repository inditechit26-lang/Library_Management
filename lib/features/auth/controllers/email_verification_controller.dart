import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

enum EmailVerificationPhase { ready, sending, pending, checking, verified }

class EmailVerificationState {
  const EmailVerificationState({
    this.phase = EmailVerificationPhase.ready,
    this.resendSeconds = 0,
    this.message,
    this.error,
  });

  final EmailVerificationPhase phase;
  final int resendSeconds;
  final String? message;
  final Object? error;

  bool get isVerified => phase == EmailVerificationPhase.verified;
  bool get canResend =>
      resendSeconds == 0 && phase == EmailVerificationPhase.pending;

  EmailVerificationState copyWith({
    EmailVerificationPhase? phase,
    int? resendSeconds,
    String? message,
    Object? error,
    bool clearError = false,
  }) => EmailVerificationState(
    phase: phase ?? this.phase,
    resendSeconds: resendSeconds ?? this.resendSeconds,
    message: message ?? this.message,
    error: clearError ? null : error ?? this.error,
  );
}

class EmailVerificationController extends Notifier<EmailVerificationState> {
  Timer? _pollTimer;
  Timer? _countdownTimer;
  bool _checking = false;

  @override
  EmailVerificationState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _countdownTimer?.cancel();
    });
    Future<void>.microtask(checkStatus);
    return const EmailVerificationState();
  }

  Future<void> sendVerificationEmail() async {
    if (state.phase == EmailVerificationPhase.sending || state.isVerified) {
      return;
    }
    state = state.copyWith(
      phase: EmailVerificationPhase.sending,
      clearError: true,
    );
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      state = state.copyWith(
        phase: EmailVerificationPhase.pending,
        message:
            'Verification email sent successfully. Please check your inbox and spam folder.',
        resendSeconds: 60,
      );
      _startCountdown();
      _startPolling();
    } catch (error) {
      state = state.copyWith(phase: EmailVerificationPhase.ready, error: error);
    }
  }

  Future<void> resendVerificationEmail() async {
    if (!state.canResend) return;
    await sendVerificationEmail();
  }

  Future<void> checkStatus() async {
    if (_checking || state.isVerified) return;
    _checking = true;
    final previousPhase = state.phase;
    state = state.copyWith(
      phase: EmailVerificationPhase.checking,
      clearError: true,
    );
    try {
      final user = await ref.read(authRepositoryProvider).reloadCurrentUser();
      if (user == null) {
        state = state.copyWith(
          phase: EmailVerificationPhase.ready,
          error: StateError('Your session has expired. Please sign in again.'),
        );
        return;
      }
      if (user.emailVerified) {
        await ref.read(authRepositoryProvider).markEmailVerified(user.uid);
        state = state.copyWith(
          phase: EmailVerificationPhase.verified,
          message: 'Email verified successfully.',
          resendSeconds: 0,
        );
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        ref.invalidate(authStateProvider);
        ref.invalidate(userProfileProvider);
      } else {
        state = state.copyWith(
          phase: previousPhase == EmailVerificationPhase.ready
              ? EmailVerificationPhase.ready
              : EmailVerificationPhase.pending,
        );
      }
    } catch (error) {
      state = state.copyWith(
        phase: previousPhase == EmailVerificationPhase.ready
            ? EmailVerificationPhase.ready
            : EmailVerificationPhase.pending,
        error: error,
      );
    } finally {
      _checking = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkStatus(),
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(resendSeconds: 0);
      } else {
        state = state.copyWith(resendSeconds: next);
      }
    });
  }
}
