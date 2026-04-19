import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/railway_type_cubit.dart';
import '../enums/railway_type.dart';
import '../theme/railway_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/home', label: '首頁', icon: Icons.home_outlined, activeIcon: Icons.home),
    _TabItem(path: '/timetable', label: '時刻表', icon: Icons.schedule_outlined, activeIcon: Icons.schedule),
    _TabItem(path: '/my-tickets', label: '我的車票', icon: Icons.confirmation_number_outlined, activeIcon: Icons.confirmation_number),
    _TabItem(path: '/profile', label: '我的', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return BlocProvider(
      create: (_) => RailwayTypeCubit(),
      child: BlocBuilder<RailwayTypeCubit, RailwayType>(
        builder: (context, railwayType) {
          final theme = RailwayTheme.of(railwayType);
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xEEFFFFFF),
              selectedItemColor: theme.accent,
              unselectedItemColor: const Color(0xFFAABBCC),
              selectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              elevation: 10,
              onTap: (index) => context.go(_tabs[index].path),
              items: _tabs
                  .asMap()
                  .entries
                  .map(
                    (e) => BottomNavigationBarItem(
                      icon: Icon(e.value.icon),
                      activeIcon: Icon(e.value.activeIcon),
                      label: e.value.label,
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class _TabItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
