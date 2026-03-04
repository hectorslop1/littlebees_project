import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../design_system/theme/app_colors.dart';
import '../../core/i18n/app_translations.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    return Scaffold(
      body: child,
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
            currentIndex: _calculateSelectedIndex(context),
            onTap: (int idx) => _onItemTapped(idx, context),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.home),
                activeIcon: const Icon(LucideIcons.home),
                label: tr.tr('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.camera),
                activeIcon: const Icon(LucideIcons.camera),
                label: tr.tr('activity'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.messageCircle),
                activeIcon: const Icon(LucideIcons.messageCircle),
                label: tr.tr('chat'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.calendar),
                activeIcon: const Icon(LucideIcons.calendar),
                label: tr.tr('calendar'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.user),
                activeIcon: const Icon(LucideIcons.user),
                label: tr.tr('me'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/activity')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/calendar')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/activity');
        break;
      case 2:
        context.go('/messages');
        break;
      case 3:
        context.go('/calendar');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
