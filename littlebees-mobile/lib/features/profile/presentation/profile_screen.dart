import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../routing/route_names.dart';
import '../../auth/application/auth_provider.dart';
import 'widgets/theme_switcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr.tr('profile'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(
              child: LBAvatar(
                placeholder: 'G',
                size: LBAvatarSize.large,
                imageUrl: 'https://i.pravatar.cc/150?u=carlos',
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'García Family',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Little Bees Daycare',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              tr.tr('children'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LBCard(
              child: Column(
                children: [
                  _buildChildRow(
                    'Emma García',
                    'Butterflies',
                    'https://i.pravatar.cc/150?u=emma',
                  ),
                  const Divider(height: 32),
                  _buildChildRow('Lucas García', 'Ladybugs', null),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              tr.tr('settings'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ThemeSwitcher(),
            const SizedBox(height: 16),
            LBCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsRow(
                    context,
                    LucideIcons.users,
                    tr.tr('familyInfo'),
                  ),
                  const Divider(height: 1),
                  _buildSettingsRow(
                    context,
                    LucideIcons.car,
                    tr.tr('authPickups'),
                  ),
                  const Divider(height: 1),
                  _buildSettingsRow(
                    context,
                    LucideIcons.bellRing,
                    tr.tr('notifications'),
                  ),
                  const Divider(height: 1),
                  _buildSettingsRow(
                    context,
                    LucideIcons.creditCard,
                    tr.tr('billing'),
                    onTap: () => context.pushNamed(RouteNames.payments),
                  ),
                  const Divider(height: 1),
                  _buildSettingsRow(
                    context,
                    LucideIcons.settings,
                    tr.tr('settings'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.globe,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      tr.tr('language'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'es', label: Text('ES')),
                      ],
                      selected: {currentLocale.languageCode},
                      onSelectionChanged: (Set<String> newSelection) {
                        ref.read(localeProvider.notifier).state = Locale(
                          newSelection.first,
                        );
                      },
                      style: ButtonStyle(visualDensity: VisualDensity.compact),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  // Router redirect will handle navigation to login
                },
                child: Text(
                  tr.tr('signOut'),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildRow(String name, String classroom, String? url) {
    return Row(
      children: [
        LBAvatar(placeholder: name, imageUrl: url, size: LBAvatarSize.small),
        const SizedBox(width: 16),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const Spacer(),
        Text(classroom, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigating to $title...'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
