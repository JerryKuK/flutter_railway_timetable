import 'package:go_router/go_router.dart';
import '../../features/home/presentation/page/home_page.dart';
import '../../features/timetable/presentation/page/timetable_page.dart';
import '../../features/my_tickets/presentation/page/my_tickets_page.dart';
import '../../features/profile/presentation/page/profile_page.dart';
import '../widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/timetable',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final origin = extra?['origin'] as String? ?? '';
            final destination = extra?['destination'] as String? ?? '';
            return NoTransitionPage(
              child: TimetablePage(
                origin: origin,
                destination: destination,
                date: extra?['date'] as String? ?? '',
                time: extra?['time'] as String? ?? '',
                originName: extra?['originName'] as String? ?? origin,
                destinationName:
                    extra?['destinationName'] as String? ?? destination,
              ),
            );
          },
        ),
        GoRoute(
          path: '/my-tickets',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MyTicketsPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),
  ],
);
