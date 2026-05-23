import 'package:go_router/go_router.dart';

import '../../features/habits/screens/add_habit_screen.dart';
import '../../features/habits/screens/home_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../shared/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/statistics',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatisticsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/habits/new',
      builder: (context, state) => const AddHabitScreen(),
    ),
  ],
);
