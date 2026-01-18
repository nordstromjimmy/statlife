import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../application/auth/auth_controller.dart';
import '../presentation/screens/day_screen.dart';
import '../presentation/screens/home_shell.dart';
import '../presentation/screens/plan_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/welcome_screen.dart';
import '../presentation/screens/signup_screen.dart';
import '../presentation/screens/signin_screen.dart';

// 🔧 DEV MODE: Set to true to always show welcome screen
const _kAlwaysShowWelcome = false;

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: _kAlwaysShowWelcome ? '/welcome' : '/day',
    redirect: (context, state) {
      final auth = authState.value;

      // Still loading auth state
      if (authState.isLoading || auth == null) {
        return null;
      }

      final isOnWelcome = state.matchedLocation == '/welcome';
      final isOnAuth =
          state.matchedLocation.startsWith('/signin') ||
          state.matchedLocation.startsWith('/signup');

      // 🔧 DEV MODE: Skip auth checks if always showing welcome
      if (_kAlwaysShowWelcome && !isOnWelcome && !isOnAuth) {
        return '/welcome';
      }

      // If user hasn't seen welcome, redirect to welcome
      if (!auth.hasSeenWelcome && !isOnWelcome && !isOnAuth) {
        return '/welcome';
      }

      // If user has seen welcome but is still on welcome page, go to app
      if (auth.hasSeenWelcome && isOnWelcome && !_kAlwaysShowWelcome) {
        return '/day';
      }

      return null;
    },
    routes: [
      // Welcome & Auth Routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),

      // Main App Shell
      ShellRoute(
        builder: (context, state, child) =>
            HomeShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/day/:dateKey',
            builder: (context, state) {
              final key = state.pathParameters['dateKey'];
              DateTime? parsed;
              if (key != null) {
                try {
                  // Parse the date: format is yyyyMMdd like "20260118"
                  final year = int.parse(key.substring(0, 4));
                  final month = int.parse(key.substring(4, 6));
                  final day = int.parse(key.substring(6, 8));
                  parsed = DateTime(year, month, day);
                } catch (_) {
                  // invalid key, fallback
                }
              }

              return DayScreen(key: ValueKey('day_$key'), initialDay: parsed);
            },
          ),
          GoRoute(
            path: '/day',
            redirect: (context, state) {
              final today = DateTime.now();
              final key = DateFormat('yyyyMMdd').format(today);
              return '/day/$key';
            },
          ),
          GoRoute(
            path: '/plan',
            builder: (context, state) => const PlanScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
