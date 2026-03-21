import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/theme/app_colors.dart';
import '../../core/i18n/app_translations.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/ai_assistant/presentation/ai_assistant_fab.dart';
import '../../routing/role_navigation.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.role;

    // Obtener items de navegación según el rol
    final navigationItems = RoleNavigation.getNavigationItems(userRole);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = RoleNavigation.calculateSelectedIndex(
      location,
      navigationItems,
    );

    return Scaffold(
      body: child,
      floatingActionButton: const AiAssistantFab(),
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
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
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
