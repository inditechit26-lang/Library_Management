import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/screens/subscription_gate_screen.dart';
import '../providers/membership_provider.dart';
import '../../settings/providers/active_library_provider.dart';
import 'navigation_guard.dart';

class MembershipGuard extends ConsumerWidget {
  const MembershipGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(membershipProvider);
    return subscription.when(
      loading: () =>
          const Material(child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => _MembershipLoadError(
        onRetry: () => ref.invalidate(membershipProvider),
      ),
      data: (value) {
        if (value == null) {
          return const Material(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!NavigationGuard.canEnterApplication(value)) {
          return SubscriptionGateScreen(
            subscription: value,
            fallbackLibraryName: ref.watch(activeLibraryProvider).name,
          );
        }
        return child;
      },
    );
  }
}

class _MembershipLoadError extends StatelessWidget {
  const _MembershipLoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Unable to Verify Membership',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your internet connection. Membership verification is required to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    ),
  );
}
