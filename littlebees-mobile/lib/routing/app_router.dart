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
import '../features/messaging/presentation/call_screen.dart';
import '../features/messaging/presentation/teacher_chat_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/activity/domain/photo_model.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/groups/presentation/groups_screen.dart';
import '../features/attendance/presentation/teacher_attendance_screen.dart';
import '../features/children/presentation/children_list_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/excuses/presentation/excuses_list_screen.dart';
import '../features/excuses/presentation/create_excuse_screen.dart';
import '../features/excuses/presentation/excuse_detail_screen.dart';
import '../features/child_profile/presentation/child_profile_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/groups/presentation/group_detail_screen.dart';
import '../features/profile/presentation/notification_settings_screen.dart';
import '../features/profile/presentation/my_children_screen.dart';
import '../features/messaging/presentation/new_conversation_screen.dart';
import '../features/families/presentation/families_screen.dart';
import '../features/ai_assistant/presentation/ai_assistant_fab.dart';
import '../features/ai_assistant/presentation/ai_voice_session_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(() => notifier.dispose());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.isAuthenticated;
      final isOnAuthPage = state.matchedLocation.startsWith('/auth');
      final isOnSplash = state.matchedLocation == '/';

      if (isLoading) return null;

      if (isOnSplash) {
        return isLoggedIn ? '/home' : '/auth/login';
      }

      if (!isLoggedIn && !isOnAuthPage) {
        return '/auth/login';
      }

      if (isLoggedIn && isOnAuthPage) {
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
        builder: (context, state, child) =>
            MainShell(currentLocation: state.matchedLocation, child: child),
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
                path: 'new',
                name: 'newConversation',
                builder: (context, state) => const NewConversationScreen(),
              ),
              GoRoute(
                path: ':conversationId',
                name: RouteNames.chat,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ChatScreen(
                    conversationId: state.pathParameters['conversationId']!,
                    participantName: extra?['participantName'] ?? 'User',
                    participantAvatarUrl: extra?['participantAvatarUrl'],
                    participantRole: extra?['participantRole'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'call',
                    name: RouteNames.chatCall,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>? ?? {};
                      return CallScreen(
                        conversationId: state.pathParameters['conversationId']!,
                        participantName:
                            extra['participantName'] as String? ?? 'Usuario',
                        participantAvatarUrl:
                            extra['participantAvatarUrl'] as String?,
                        participantRole: extra['participantRole'] as String?,
                        callType: extra['callType'] as String? ?? 'voice',
                        isOutgoing: extra['isOutgoing'] as bool? ?? true,
                        callId: extra['callId'] as String?,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'teacher/:teacherId',
                name: 'teacherChat',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return TeacherChatScreen(
                    teacherConversations:
                        extra['conversations'] as List<dynamic>,
                    teacherId: state.pathParameters['teacherId']!,
                    teacherName: extra['teacherName'] as String,
                  );
                },
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
          GoRoute(
            path: '/groups',
            name: RouteNames.groups,
            builder: (context, state) => const GroupsScreen(),
            routes: [
              GoRoute(
                path: ':groupId',
                name: RouteNames.groupDetail,
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  return GroupDetailScreen(groupId: groupId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/attendance',
            name: RouteNames.attendance,
            builder: (context, state) => const TeacherAttendanceScreen(),
          ),
          GoRoute(
            path: '/children',
            name: RouteNames.children,
            builder: (context, state) => const ChildrenListScreen(),
            routes: [
              GoRoute(
                path: ':childId/profile',
                name: RouteNames.childProfile,
                builder: (context, state) {
                  final childId = state.pathParameters['childId']!;
                  return ChildProfileScreen(childId: childId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            name: RouteNames.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/excuses',
            name: RouteNames.excuses,
            builder: (context, state) => const ExcusesListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.excuseCreate,
                builder: (context, state) => const CreateExcuseScreen(),
              ),
              GoRoute(
                path: ':excuseId',
                name: RouteNames.excuseDetail,
                builder: (context, state) => ExcuseDetailScreen(
                  excuseId: state.pathParameters['excuseId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/assistant',
            name: RouteNames.aiAssistant,
            builder: (context, state) => const AiAssistantScreen(),
            routes: [
              GoRoute(
                path: 'voice/:sessionId',
                name: RouteNames.aiAssistantVoice,
                builder: (context, state) => AiVoiceSessionScreen(
                  sessionId: state.pathParameters['sessionId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/families',
            name: RouteNames.families,
            builder: (context, state) => const FamiliesScreen(),
          ),
          GoRoute(
            path: '/notification-settings',
            name: 'notificationSettings',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: '/profile/my-children',
            name: 'myChildren',
            builder: (context, state) => const MyChildrenScreen(),
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
