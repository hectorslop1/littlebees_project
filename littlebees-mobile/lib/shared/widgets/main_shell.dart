import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/socket_client.dart';
import '../../design_system/theme/app_colors.dart';
import '../../core/i18n/app_translations.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/ai_assistant/presentation/ai_assistant_fab.dart';
import '../../features/messaging/application/call_provider.dart';
import '../../features/messaging/application/conversations_provider.dart';
import '../../routing/role_navigation.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _incomingDialogVisible = false;
  late final ProviderSubscription<IncomingCallInvitation?> _incomingCallSubscription;

  @override
  void initState() {
    super.initState();
    _incomingCallSubscription = ref.listenManual<IncomingCallInvitation?>(
      incomingCallProvider,
      (previous, next) {
        if (next == null || _incomingDialogVisible) {
          return;
        }

        _incomingDialogVisible = true;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              next.callType == 'video'
                  ? 'Videollamada entrante'
                  : 'Llamada entrante',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(next.fromName),
                const SizedBox(height: 8),
                Text(
                  next.fromRole ?? 'Contacto',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _incomingDialogVisible = false;
                  SocketClient.getSocket().then((socket) {
                    socket.emit('decline_call', {'callId': next.callId});
                  });
                  ref.read(incomingCallProvider.notifier).state = null;
                },
                child: const Text('Rechazar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _incomingDialogVisible = false;
                  ref.read(activeCallIdProvider.notifier).state = next.callId;
                  context.push(
                    '/messages/${next.conversationId}/call',
                    extra: {
                      'participantName': next.fromName,
                      'participantAvatarUrl': next.fromAvatarUrl,
                      'participantRole': next.fromRole,
                      'callType': next.callType,
                      'isOutgoing': false,
                      'callId': next.callId,
                    },
                  );
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ).then((_) {
          _incomingDialogVisible = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _incomingCallSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(callSyncProvider);
    final tr = ref.watch(translationsProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.role;
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    ref.watch(chatRealtimeSyncProvider);

    // Obtener items de navegación según el rol
    final navigationItems = RoleNavigation.getNavigationItems(userRole);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = RoleNavigation.calculateSelectedIndex(
      location,
      navigationItems,
    );
    final aiFabRoutes = {
      ...navigationItems.map((item) => item.route),
      '/payments',
    };
    final showAiFab = aiFabRoutes.contains(location);

    return Scaffold(
      body: widget.child,
      floatingActionButton: showAiFab ? const AiAssistantFab() : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (int idx) => _onItemTapped(idx, context, navigationItems),
            type: BottomNavigationBarType.fixed,
            backgroundColor: context.isDark
                ? const Color(0xFF1E1E1E)
                : AppColors.surface,
            selectedItemColor: context.isDark
                ? const Color(0xFFE5C068)
                : AppColors.primary,
            unselectedItemColor: context.isDark
                ? const Color(0xFF808080)
                : AppColors.textTertiary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: navigationItems.map((item) {
              final isMessagesItem = item.route == '/messages';
              return BottomNavigationBarItem(
                icon: _ShellNavIcon(
                  icon: item.icon,
                  badgeCount: isMessagesItem ? unreadMessages : 0,
                ),
                activeIcon: _ShellNavIcon(
                  icon: item.activeIcon,
                  badgeCount: isMessagesItem ? unreadMessages : 0,
                  active: true,
                ),
                label: tr.tr(item.labelKey),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    List<NavigationItem> items,
  ) {
    if (index >= 0 && index < items.length) {
      context.go(items[index].route);
    }
  }
}

class _ShellNavIcon extends StatelessWidget {
  const _ShellNavIcon({
    required this.icon,
    required this.badgeCount,
    this.active = false,
  });

  final IconData icon;
  final int badgeCount;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? (context.isDark ? const Color(0xFFE5C068) : AppColors.primary)
        : (context.isDark ? const Color(0xFF808080) : AppColors.textTertiary);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: iconColor),
        if (badgeCount > 0)
          Positioned(
            right: -10,
            top: -6,
            child: _UnreadBadge(count: badgeCount),
          ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
