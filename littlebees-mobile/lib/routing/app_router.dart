import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../shared/widgets/main_shell.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/activity/presentation/activity_screen.dart';
import '../features/activity/presentation/photo_viewer_screen.dart';
import '../features/messaging/presentation/conversations_screen.dart';
import '../features/messaging/presentation/chat_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/activity/domain/photo_model.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/application/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(() => notifier.dispose());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Read auth state DIRECTLY at redirect time (not captured)
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.isAuthenticated;
      final isOnAuthPage = state.matchedLocation.startsWith('/auth');
      final isOnSplash = state.matchedLocation == '/';

      print(
        '🔄 ROUTER REDIRECT: isLoading=$isLoading, isLoggedIn=$isLoggedIn, location=${state.matchedLocation}',
      );

      // While auth is loading, stay on splash
      if (isLoading) {
        return isOnSplash ? null : '/';
      }

      // Allow splash screen briefly
      if (isOnSplash) {
        return isLoggedIn ? '/home' : '/auth/login';
      }

      // If not logged in and not on auth page, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/auth/login';
      }

      // If logged in and on auth page, redirect to home
      if (isLoggedIn && isOnAuthPage) {
        print(
          '🔄 ROUTER: Redirecting authenticated user from auth page to /home',
        );
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/activity',
            name: RouteNames.activity,
            builder: (context, state) => const ActivityScreen(),
            routes: [
              GoRoute(
                path: 'photo/:photoId',
                name: RouteNames.photoViewer,
                builder: (context, state) {
                  final photo = state.extra as Photo;
                  return PhotoViewerScreen(
                    photo: photo,
                    heroTag: 'photo_${photo.id}',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/messages',
            name: RouteNames.messages,
            builder: (context, state) => const ConversationsScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                name: RouteNames.chat,
                builder: (context, state) => ChatScreen(
                  conversationId: state.pathParameters['conversationId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/calendar',
            name: RouteNames.calendar,
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/payments',
            name: RouteNames.payments,
            builder: (context, state) => const PaymentsScreen(),
          ),
        ],
      ),
    ],
  );
});

// Listens to auth state changes and notifies GoRouter to re-run redirect
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _subscription = _ref.listen(authProvider, (previous, next) {
      print(
        '🔄 AUTH NOTIFIER: isAuthenticated changed to ${next.isAuthenticated}',
      );
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
