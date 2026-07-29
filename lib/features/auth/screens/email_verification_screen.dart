import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/error_handler.dart';
import '../controllers/email_verification_controller.dart';
import '../providers/auth_provider.dart';
import '../providers/email_verification_provider.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emailVerificationProvider);
    final controller = ref.read(emailVerificationProvider.notifier);
    final email = ref.read(authRepositoryProvider).currentUser?.email ?? '';

    ref.listen(emailVerificationProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ErrorHandler.showErrorSnackBar(context, next.error);
      }
      if (next.isVerified && previous?.isVerified != true) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Email verified successfully.',
        );
        Timer(const Duration(seconds: 2), () {
          if (context.mounted) context.go('/app');
        });
      }
    });

    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: state.isVerified
                              ? colors.tertiaryContainer
                              : colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: Icon(
                            state.isVerified
                                ? Icons.verified_rounded
                                : Icons.mark_email_unread_outlined,
                            key: ValueKey(state.isVerified),
                            size: 39,
                            color: state.isVerified
                                ? colors.onTertiaryContainer
                                : colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.isVerified
                            ? 'Email Verified'
                            : 'Verify your email',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Verify your registered email address before accessing your library dashboard.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.alternate_email_rounded,
                              size: 19,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                email,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatusCard(state: state),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: state.phase == EmailVerificationPhase.ready
                              ? controller.sendVerificationEmail
                              : null,
                          icon:
                              state.phase == EmailVerificationPhase.sending ||
                                  state.phase == EmailVerificationPhase.checking
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  state.isVerified
                                      ? Icons.check_circle_rounded
                                      : state.phase ==
                                            EmailVerificationPhase.pending
                                      ? Icons.hourglass_top_rounded
                                      : Icons.email_outlined,
                                ),
                          label: Text(_primaryLabel(state)),
                          style: state.isVerified
                              ? FilledButton.styleFrom(
                                  backgroundColor: colors.tertiary,
                                  foregroundColor: colors.onTertiary,
                                )
                              : null,
                        ),
                      ),
                      if (state.phase == EmailVerificationPhase.pending) ...[
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: controller.checkStatus,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text("I've Verified My Email"),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: state.canResend
                              ? controller.resendVerificationEmail
                              : null,
                          icon: const Icon(Icons.outgoing_mail),
                          label: Text(
                            state.resendSeconds > 0
                                ? 'Resend in ${state.resendSeconds}s'
                                : 'Resend Verification Email',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: state.isVerified
                            ? null
                            : () async {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .signOut();
                                if (context.mounted) {
                                  context.go('/login?mode=signup');
                                }
                              },
                        child: const Text('Change email'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final EmailVerificationState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final verified = state.isVerified;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: verified ? colors.tertiaryContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: verified
                ? colors.onTertiaryContainer
                : colors.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              verified ? 'Email Verified' : 'Waiting for verification',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

String _primaryLabel(EmailVerificationState state) => switch (state.phase) {
  EmailVerificationPhase.ready => 'Verify Email',
  EmailVerificationPhase.sending => 'Sending Verification Email',
  EmailVerificationPhase.pending => 'Pending Verification',
  EmailVerificationPhase.checking => 'Checking Verification',
  EmailVerificationPhase.verified => 'Verified Successfully',
};
