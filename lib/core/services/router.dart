import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/students/screens/student_profile_screen.dart';
import '../../features/seats/screens/seat_profile_screen.dart';
import '../../features/seats/screens/change_seat_screen.dart';
import '../../features/seats/screens/seat_settings_screen.dart';
import '../../features/settings/screens/membership_pricing_screen.dart';
import '../../features/settings/screens/owner_profile_screen.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/app', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/students/:id',
        builder: (context, state) => StudentProfileScreen(
          studentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/settings/seats',
        builder: (context, state) => const SeatSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/pricing',
        builder: (context, state) => const MembershipPricingScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const OwnerProfileScreen(),
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
  ),
);

