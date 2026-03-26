import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/file_upload_service.dart';
import '../../../core/services/image_service.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/auth_models.dart';
import '../../../shared/models/child_model.dart';
import '../../auth/application/auth_provider.dart';
import '../../home/application/home_providers.dart';
import 'widgets/theme_switcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final currentLocale = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(tr.tr('profile'))),
      body: SafeArea(
        child: childrenAsync.when(
          data: (children) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              _ProfileHero(
                user: user,
                tenant: tenant,
                childrenCount: children.length,
              ),
              const SizedBox(height: 18),
              _ProfileOverview(
                user: user,
                childrenCount: children.length,
              ),
              const SizedBox(height: 18),
              _ChildrenSummaryCard(
                user: user,
                children: children,
              ),
              const SizedBox(height: 18),
              const ThemeSwitcher(),
              const SizedBox(height: 18),
              _SettingsSection(
                tr: tr,
                currentLocale: currentLocale.languageCode,
                onLanguageChanged: (value) {
                  ref.read(localeProvider.notifier).state = Locale(value);
                },
              ),
              const SizedBox(height: 18),
              LBCard(
                child: Column(
                  children: [
                    if (user != null &&
                        (user.role == UserRole.parent ||
                            user.role == UserRole.teacher ||
                            user.role == UserRole.director ||
                            user.role == UserRole.admin ||
                            user.role == UserRole.superAdmin)) ...[
                      _ActionRow(
                        icon: LucideIcons.fileCheck2,
                        title: 'Justificantes',
                        subtitle: user.role == UserRole.parent
                            ? 'Crea y consulta justificantes de tus hijos'
                            : 'Revisa avisos y justificantes vinculados a tus alumnos',
                        onTap: () => context.pushNamed(RouteNames.excuses),
                      ),
                      const Divider(height: 24),
                    ],
                    _ActionRow(
                      icon: LucideIcons.creditCard,
                      title: tr.tr('billing'),
                      subtitle: 'Estado de cuenta y pagos registrados',
                      onTap: () => context.pushNamed(RouteNames.payments),
                    ),
                    const Divider(height: 24),
                    _ActionRow(
                      icon: LucideIcons.bellRing,
                      title: tr.tr('notifications'),
                      subtitle: 'Alertas, mensajes y recordatorios',
                      onTap: () => context.push('/notifications'),
                    ),
                    const Divider(height: 24),
                    _ActionRow(
                      icon: LucideIcons.messageCircle,
                      title: tr.tr('chat'),
                      subtitle: 'Conversaciones con maestras y dirección',
                      onTap: () => context.pushNamed(RouteNames.messages),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(LucideIcons.logOut, color: AppColors.error),
                  label: Text(
                    tr.tr('signOut'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'LittleBees v1.0.0',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LBCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      size: 52,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No fue posible cargar el perfil',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends ConsumerStatefulWidget {
  const _ProfileHero({
    required this.user,
    required this.tenant,
    required this.childrenCount,
  });

  final UserInfo? user;
  final TenantInfo? tenant;
  final int childrenCount;

  @override
  ConsumerState<_ProfileHero> createState() => _ProfileHeroState();
}

class _ProfileHeroState extends ConsumerState<_ProfileHero> {
  final ImageService _imageService = ImageService();
  final FileUploadService _fileUploadService = FileUploadService();
  bool _isUploadingAvatar = false;

  Future<void> _changeAvatar() async {
    final option = await showModalBottomSheet<_AvatarSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (option == null) return;

    try {
      final file = option == _AvatarSource.camera
          ? await _imageService.capturePhoto()
          : await _imageService.pickFromGallery();
      if (file == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final uploaded = await _fileUploadService.uploadFile(
        file: file,
        purpose: 'user_avatar',
      );

      await ref.read(authProvider.notifier).updateAvatar(uploaded.fileId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar la foto: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final tenant = widget.tenant;
    final childrenCount = widget.childrenCount;
    final initials = user == null
        ? 'U'
        : '${user.firstName.isNotEmpty ? user.firstName[0] : 'U'}${user.lastName.isNotEmpty ? user.lastName[0] : ''}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F0DE), Color(0xFFFFFFFF), Color(0xFFF0F5EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _roleLabel(user?.role),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.baby, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      '$childrenCount perfiles',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Stack(
            clipBehavior: Clip.none,
            children: [
              LBAvatar(
                placeholder: initials,
                size: LBAvatarSize.large,
                imageUrl: user?.avatarUrl,
                heroTag: 'profile-avatar-${user?.id ?? 'guest'}',
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isUploadingAvatar ? null : _changeAvatar,
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: _isUploadingAvatar
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              LucideIcons.camera,
                              size: 16,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Usuario',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            tenant?.name ?? 'Institución',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _AvatarSource { camera, gallery }

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({
    required this.user,
    required this.childrenCount,
  });

  final UserInfo? user;
  final int childrenCount;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Rol',
        _roleLabel(user?.role),
        LucideIcons.badgeCheck,
        AppColors.primary,
      ),
      (
        'Familia',
        '$childrenCount vinculados',
        LucideIcons.users,
        AppColors.secondary,
      ),
      (
        'Contacto',
        user?.phone ?? 'Sin teléfono',
        LucideIcons.phone,
        AppColors.info,
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == items.last ? 0 : 12,
                ),
                child: LBCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.$3, color: item.$4, size: 18),
                      const SizedBox(height: 14),
                      Text(
                        item.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ChildrenSummaryCard extends StatelessWidget {
  const _ChildrenSummaryCard({
    required this.user,
    required this.children,
  });

  final UserInfo? user;
  final List<Child> children;

  @override
  Widget build(BuildContext context) {
    final title = user?.role == UserRole.parent ? 'Mis hijos' : 'Mis alumnos';

    return LBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (children.length > 1)
                TextButton(
                  onPressed: () => context.push('/profile/my-children'),
                  child: const Text('Ver todos'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (children.isEmpty)
            const Text(
              'No hay perfiles vinculados por el momento.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            )
          else ...[
            ...children.take(3).map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CompactChildRow(child: child),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactChildRow extends StatelessWidget {
  const _CompactChildRow({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/children/${child.id}/profile'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            LBAvatar(
              placeholder: child.firstName.isNotEmpty ? child.firstName[0] : 'N',
              imageUrl: child.photoUrl,
              size: LBAvatarSize.small,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${child.firstName} ${child.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    child.groupName ?? 'Sin grupo asignado',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.tr,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  final dynamic tr;
  final String currentLocale;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return LBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.tr('settings'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.palette, color: AppColors.primary),
            title: const Text(
              'Tema visual',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Personaliza la apariencia de la app'),
            trailing: const SizedBox(width: 84, child: ThemeSwitcher()),
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.globe, color: AppColors.primary),
            title: Text(
              tr.tr('language'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Cambia el idioma de la experiencia'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'es', label: Text('ES')),
              ],
              selected: {currentLocale},
              onSelectionChanged: (selection) {
                onLanguageChanged(selection.first);
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

String _roleLabel(UserRole? role) {
  switch (role) {
    case UserRole.parent:
      return 'Padre de familia';
    case UserRole.teacher:
      return 'Maestra';
    case UserRole.director:
      return 'Directiva';
    case UserRole.admin:
    case UserRole.superAdmin:
      return 'Administrador';
    default:
      return 'Usuario';
  }
}
