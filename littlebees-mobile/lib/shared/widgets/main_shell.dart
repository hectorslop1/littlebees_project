import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api/socket_client.dart';
import '../../design_system/theme/app_colors.dart';
import '../../design_system/widgets/lb_avatar.dart';
import '../../core/i18n/app_translations.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/ai_assistant/presentation/ai_assistant_fab.dart';
import '../../features/messaging/application/call_provider.dart';
import '../../features/messaging/application/conversations_provider.dart';
import '../../features/messaging/presentation/call_screen.dart';
import '../../features/messaging/presentation/chat_screen.dart';
import '../../features/messaging/presentation/conversations_screen.dart';
import '../../features/messaging/presentation/new_conversation_screen.dart';
import '../../routing/role_navigation.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentLocation;

  const MainShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  Future<void> _rejectIncomingCall(IncomingCallInvitation call) async {
    await stopIncomingCallAlert();
    final socket = await SocketClient.getSocket();
    socket.emit('decline_call', {'callId': call.callId});
    ref.read(incomingCallProvider.notifier).state = null;
  }

  Future<void> _acceptIncomingCall(IncomingCallInvitation call) async {
    await stopIncomingCallAlert();
    ref.read(incomingCallProvider.notifier).state = null;
    ref.read(activeCallIdProvider.notifier).state = call.callId;

    if (!mounted) return;

    context.push(
      '/messages/${call.conversationId}/call',
      extra: {
        'participantName': call.fromName,
        'participantAvatarUrl': call.fromAvatarUrl,
        'participantRole': call.fromRole,
        'callType': call.callType,
        'isOutgoing': false,
        'callId': call.callId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(callSyncProvider);
    final tr = ref.watch(translationsProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.role;
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    final incomingCall = ref.watch(incomingCallProvider);
    final activeCallId = ref.watch(activeCallIdProvider);
    ref.watch(chatRealtimeSyncProvider);

    // Obtener items de navegación según el rol
    final navigationItems = RoleNavigation.getNavigationItems(userRole);
    final location = GoRouter.of(context).routeInformationProvider.value.uri.path;
    final currentIndex = RoleNavigation.calculateSelectedIndex(
      location,
      navigationItems,
    );
    final aiFabRoutes = {
      '/home',
      '/activity',
      '/groups',
      '/reports',
      '/profile',
      '/payments',
      '/children',
    };
    final showIncomingCallScreen =
        incomingCall != null && activeCallId != incomingCall.callId;
    final child = widget.child;
    final isExcludedChildScreen =
        child is ConversationsScreen ||
        child is ChatScreen ||
        child is CallScreen ||
        child is NewConversationScreen ||
        child is AiAssistantScreen;
    final showAiFab =
        aiFabRoutes.contains(location) &&
        !showIncomingCallScreen &&
        !isExcludedChildScreen;

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (incomingCall != null && showIncomingCallScreen)
            Positioned.fill(
              child: _IncomingCallScreen(
                call: incomingCall,
                onAccept: () => _acceptIncomingCall(incomingCall),
                onReject: () => _rejectIncomingCall(incomingCall),
              ),
            ),
        ],
      ),
      floatingActionButton: showAiFab ? const AiAssistantFab() : null,
      bottomNavigationBar: showIncomingCallScreen
          ? null
          : Container(
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (int idx) =>
                      _onItemTapped(idx, context, navigationItems),
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
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  iconSize: 20,
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

class _IncomingCallScreen extends StatelessWidget {
  const _IncomingCallScreen({
    required this.call,
    required this.onAccept,
    required this.onReject,
  });

  final IncomingCallInvitation call;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isVideo = call.callType == 'video';

    return ColoredBox(
      color: const Color(0xFF101214),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Text(
              isVideo ? 'Videollamada entrante' : 'Llamada entrante',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            LBAvatar(
              placeholder: call.fromName.isNotEmpty ? call.fromName[0] : 'U',
              imageUrl: call.fromAvatarUrl,
              size: LBAvatarSize.large,
            ),
            const SizedBox(height: 18),
            Text(
              call.fromName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              call.fromRole ?? 'Contacto escolar',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isVideo
                    ? 'Toca para aceptar videollamada'
                    : 'Toca para aceptar llamada',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _IncomingCallAction(
                    icon: LucideIcons.phoneOff,
                    label: 'Rechazar',
                    backgroundColor: AppColors.error,
                    onTap: onReject,
                  ),
                  _IncomingCallAction(
                    icon: isVideo ? LucideIcons.video : LucideIcons.phone,
                    label: 'Aceptar',
                    backgroundColor: AppColors.success,
                    onTap: onAccept,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingCallAction extends StatelessWidget {
  const _IncomingCallAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 84,
              height: 84,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
