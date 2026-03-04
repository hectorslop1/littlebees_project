import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardTab(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarTab(),
          ),
          GoRoute(
            path: '/development',
            builder: (context, state) => const DevelopmentTab(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatTab(),
          ),
          GoRoute(
            path: '/menu',
            builder: (context, state) => const MenuTab(),
          ),
        ],
      ),
    ],
  );
});

// Placeholder tab widgets
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Dashboard'));
}

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Calendario'));
}

class DevelopmentTab extends StatelessWidget {
  const DevelopmentTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Desarrollo'));
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Chat'));
}

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Menú'));
}
