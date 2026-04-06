import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api/socket_client.dart';
import '../../design_system/theme/app_colors.dart';
import '../../design_system/widgets/lb_avatar.dart';
import '../../core/i18n/app_translations.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/ai_assistant/presentation/ai_assistant_fab.dart';
import '../../features/ai_assistant/presentation/ai_voice_session_screen.dart';
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
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
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
    final isAssistantRoute = location.startsWith('/assistant');
    final isExcludedChildScreen =
        child is ConversationsScreen ||
        child is ChatScreen ||
        child is CallScreen ||
        child is NewConversationScreen ||
        child is AiAssistantScreen ||
        child is AiVoiceSessionScreen;
    final hideBottomNavigation =
        isExcludedChildScreen || showIncomingCallScreen || isAssistantRoute;
    final showAiFab =
        aiFabRoutes.contains(location) &&
        !showIncomingCallScreen &&
        !isExcludedChildScreen &&
        !isAssistantRoute;

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
      bottomNavigationBar: hideBottomNavigation
          ? null
          : _PremiumBottomNav(
              items: navigationItems,
              currentIndex: currentIndex,
              unreadMessages: unreadMessages,
              tr: tr,
              onTap: (idx) => _onItemTapped(idx, context, navigationItems),
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

class _PremiumBottomNav extends StatelessWidget {
  const _PremiumBottomNav({
    required this.items,
    required this.currentIndex,
    required this.unreadMessages,
    required this.tr,
    required this.onTap,
  });

  final List<NavigationItem> items;
  final int currentIndex;
  final int unreadMessages;
  final AppTranslations tr;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final activeColor = isDark ? const Color(0xFFE5C068) : AppColors.primary;
    final inactiveColor = isDark
        ? const Color(0xFF808080)
        : AppColors.textTertiary;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomPadding, top: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E).withAlpha(230)
                : AppColors.surface.withAlpha(235),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.black.withAlpha(8),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              final isMessages = item.route == '/messages';
              final badge = isMessages ? unreadMessages : 0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                  child: _PremiumNavItem(
                    icon: isActive ? item.activeIcon : item.icon,
                    label: tr.tr(item.labelKey),
                    isActive: isActive,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    badgeCount: badge,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PremiumNavItem extends StatelessWidget {
  const _PremiumNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.badgeCount,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isActive ? 32 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icon + badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 22,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -10,
                  top: -6,
                  child: _UnreadBadge(count: badgeCount),
                ),
            ],
          ),
          const SizedBox(height: 3),
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
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
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.isDark ? const Color(0xFF1E1E1E) : Colors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
