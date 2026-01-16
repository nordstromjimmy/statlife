import 'package:go_router/go_router.dart';

import '../presentation/screens/day_screen.dart';
import '../presentation/screens/home_shell.dart';
import '../presentation/screens/plan_screen.dart';
import '../presentation/screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/day',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomeShell(location: state.uri.toString(), child: child);
      },
      routes: [
        GoRoute(path: '/day', builder: (context, state) => const DayScreen()),
        GoRoute(
          path: '/day/:date',
          builder: (context, state) {
            final raw = state.pathParameters['date']!;
            final y = int.parse(raw.substring(0, 4));
            final m = int.parse(raw.substring(4, 6));
            final d = int.parse(raw.substring(6, 8));
            return DayScreen(initialDay: DateTime(y, m, d));
          },
        ),
        GoRoute(path: '/plan', builder: (context, state) => const PlanScreen()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
