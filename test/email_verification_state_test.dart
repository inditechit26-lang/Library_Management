import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter/features/auth/controllers/email_verification_controller.dart';

void main() {
  test('verification actions follow secure button states', () {
    const ready = EmailVerificationState();
    expect(ready.phase, EmailVerificationPhase.ready);
    expect(ready.canResend, isFalse);
    expect(ready.isVerified, isFalse);

    final pending = ready.copyWith(
      phase: EmailVerificationPhase.pending,
      resendSeconds: 60,
    );
    expect(pending.canResend, isFalse);

    final resendReady = pending.copyWith(resendSeconds: 0);
    expect(resendReady.canResend, isTrue);

    final verified = resendReady.copyWith(
      phase: EmailVerificationPhase.verified,
    );
    expect(verified.isVerified, isTrue);
    expect(verified.canResend, isFalse);
  });
}
