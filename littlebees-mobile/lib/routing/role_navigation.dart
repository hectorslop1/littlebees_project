import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../shared/enums/enums.dart';

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.route,
  });
}

class RoleNavigation {
  static List<NavigationItem> getNavigationItems(UserRole? role) {
    switch (role) {
      case UserRole.parent:
        return _parentNavigation;
      case UserRole.teacher:
        return _teacherNavigation;
      case UserRole.director:
        return _directorNavigation;
      case UserRole.admin:
      case UserRole.superAdmin:
        return _adminNavigation;
      default:
        return _defaultNavigation;
    }
  }

  // Navegación para Padres
  static const List<NavigationItem> _parentNavigation = [
    NavigationItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      labelKey: 'home',
      route: '/home',
    ),
    NavigationItem(
      icon: LucideIcons.baby,
      activeIcon: LucideIcons.baby,
      labelKey: 'my_children',
      route: '/children',
    ),
    NavigationItem(
      icon: LucideIcons.messageCircle,
      activeIcon: LucideIcons.messageCircle,
      labelKey: 'chat',
      route: '/messages',
    ),
    NavigationItem(
      icon: LucideIcons.user,
      activeIcon: LucideIcons.user,
      labelKey: 'me',
      route: '/profile',
    ),
  ];

  // Navegación para Maestras
  static const List<NavigationItem> _teacherNavigation = [
    NavigationItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      labelKey: 'home',
      route: '/home',
    ),
    NavigationItem(
      icon: LucideIcons.camera,
      activeIcon: LucideIcons.camera,
      labelKey: 'activity',
      route: '/activity',
    ),
    NavigationItem(
      icon: LucideIcons.users,
      activeIcon: LucideIcons.users,
      labelKey: 'groups',
      route: '/groups',
    ),
    NavigationItem(
      icon: LucideIcons.user,
      activeIcon: LucideIcons.user,
      labelKey: 'me',
      route: '/profile',
    ),
  ];

  // Navegación para Directora
  static const List<NavigationItem> _directorNavigation = [
    NavigationItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      labelKey: 'home',
      route: '/home',
    ),
    NavigationItem(
      icon: LucideIcons.users,
      activeIcon: LucideIcons.users,
      labelKey: 'groups',
      route: '/groups',
    ),
    NavigationItem(
      icon: LucideIcons.barChart3,
      activeIcon: LucideIcons.barChart3,
      labelKey: 'reports',
      route: '/reports',
    ),
    NavigationItem(
      icon: LucideIcons.messageCircle,
      activeIcon: LucideIcons.messageCircle,
      labelKey: 'chat',
      route: '/messages',
    ),
    NavigationItem(
      icon: LucideIcons.user,
      activeIcon: LucideIcons.user,
      labelKey: 'me',
      route: '/profile',
    ),
  ];

  // Navegación para Admin/Super Admin
  static const List<NavigationItem> _adminNavigation = [
    NavigationItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      labelKey: 'home',
      route: '/home',
    ),
    NavigationItem(
      icon: LucideIcons.users,
      activeIcon: LucideIcons.users,
      labelKey: 'groups',
      route: '/groups',
    ),
    NavigationItem(
      icon: LucideIcons.settings,
      activeIcon: LucideIcons.settings,
      labelKey: 'settings',
      route: '/profile',
    ),
    NavigationItem(
      icon: LucideIcons.messageCircle,
      activeIcon: LucideIcons.messageCircle,
      labelKey: 'chat',
      route: '/messages',
    ),
    NavigationItem(
      icon: LucideIcons.user,
      activeIcon: LucideIcons.user,
      labelKey: 'me',
      route: '/profile',
    ),
  ];

  // Navegación por defecto (fallback)
  static const List<NavigationItem> _defaultNavigation = [
    NavigationItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      labelKey: 'home',
      route: '/home',
    ),
    NavigationItem(
      icon: LucideIcons.user,
      activeIcon: LucideIcons.user,
      labelKey: 'me',
      route: '/profile',
    ),
  ];

  // Helper para calcular el índice seleccionado basado en la ruta actual
  static int calculateSelectedIndex(
    String location,
    List<NavigationItem> items,
  ) {
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) {
        return i;
      }
    }
    return 0;
  }
}
