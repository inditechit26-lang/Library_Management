import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/students/screens/student_profile_screen.dart';
import '../../features/seats/screens/seat_profile_screen.dart';
import '../../features/seats/screens/change_seat_screen.dart';
import '../../features/seats/screens/seat_settings_screen.dart';
import '../../features/settings/screens/owner_profile_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/notifications/screens/notification_settings_screen.dart';
import '../../features/settings/screens/about_us_screen.dart';
import '../../features/settings/screens/privacy_policy_screen.dart';
import '../../features/settings/screens/payment_settings_screen.dart';
import '../../features/settings/screens/library_configuration_screen.dart';
import '../../features/settings/screens/libraries_screen.dart';
import '../../features/settings/screens/student_data_management_screen.dart';
import '../../features/settings/screens/whatsapp_templates_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../widgets/app_shell.dart';

import '../../features/update/screens/update_center_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/app',
    refreshListenable: GoRouterRefreshStream(authRepo.authStateChanges),
    redirect: (context, state) async {
      final user = authRepo.currentUser;
      final loggingIn = state.matchedLocation == '/login';
      final verifying = state.matchedLocation == '/verify-email';

      if (user == null && !loggingIn) {
        return '/login';
      }
      if (user == null) return null;

      try {
        final refreshedUser = await authRepo.reloadCurrentUser();
        if (refreshedUser == null) return '/login';
        if (!refreshedUser.emailVerified) {
          return verifying ? null : '/verify-email';
        }
      } catch (_) {
        return verifying ? null : '/verify-email';
      }

      if (loggingIn || verifying) return '/app';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          showSignup: state.uri.queryParameters['mode'] == 'signup',
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final userId = ref.watch(authStateProvider).value?.uid;
            return AppShell(key: ValueKey(userId));
          },
        ),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/notifications/settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/students/:id',
        builder: (context, state) => StudentProfileScreen(
          studentId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        path: '/settings/seats',
        builder: (context, state) => const SeatSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/libraries',
        builder: (context, state) => const LibrariesScreen(),
      ),
      GoRoute(
        path: '/settings/library-configuration',
        builder: (context, state) => const LibraryConfigurationScreen(),
      ),
      GoRoute(
        path: '/settings/data-management',
        builder: (context, state) => const StudentDataManagementScreen(),
      ),
      GoRoute(
        path: '/settings/payment',
        builder: (context, state) => const PaymentSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/whatsapp-templates',
        builder: (context, state) => const WhatsappTemplatesScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const OwnerProfileScreen(),
      ),
      GoRoute(
        path: '/settings/update',
        builder: (context, state) => const UpdateCenterScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/seats/:number',
        builder: (context, state) =>
            SeatProfileScreen(seatId: state.pathParameters['number']!),
      ),
      GoRoute(
        path: '/seats/:number/change',
        builder: (context, state) =>
            ChangeSeatScreen(currentSeat: state.pathParameters['number']!),
      ),
    ],
  );
});
