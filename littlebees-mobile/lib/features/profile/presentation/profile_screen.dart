import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/file_upload_service.dart';
import '../../../core/services/image_service.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/auth_models.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../auth/application/auth_provider.dart';
import '../../ai_assistant/presentation/ai_assistant_fab.dart';
import '../../ai_assistant/presentation/widgets/beea_avatar.dart';
import '../../home/application/home_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);
    final childrenAsync = ref.watch(myChildrenProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final isParent = user?.role == UserRole.parent;
    final isTeacher = user?.role == UserRole.teacher;
    final isDirector =
        user?.role == UserRole.director ||
        user?.role == UserRole.admin ||
        user?.role == UserRole.superAdmin;

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(title: Text(tr.tr('profile'))),
      body: SafeArea(
        child: childrenAsync.when(
          data: (children) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _ProfileHero(
                user: user,
                tenant: tenant,
                childrenCount: children.length,
              ),
              const SizedBox(height: 14),
              _ProfileOverview(user: user, childrenCount: children.length),
              if (isParent || isTeacher) ...[
                const SizedBox(height: 14),
                _ChildrenSummaryCard(user: user, children: children),
              ],
              const SizedBox(height: 14),
              _SettingsSection(
                tr: tr,
                isDarkMode: isDarkMode,
                onToggleTheme: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                currentLocale: currentLocale.languageCode,
                onLanguageChanged: (value) {
                  ref.read(localeProvider.notifier).state = Locale(value);
                },
              ),
              const SizedBox(height: 14),
              LBCard(
                child: Column(
                  children: [
                    if (user != null) ...[
                      _ActionRow(
                        leading: const BeeaAvatar(size: 40),
                        title: 'Beea',
                        subtitle: 'Tu asistente con contexto real según tu rol',
                        onTap: () => showAiAssistantSheet(context),
                      ),
                      const Divider(height: 24),
                      _ActionRow(
                        icon: LucideIcons.fileCheck2,
                        title: 'Justificantes',
                        subtitle: isParent
                            ? 'Crea y consulta justificantes de tus hijos'
                            : 'Revisa avisos y justificantes vinculados a tus alumnos',
                        onTap: () => context.pushNamed(RouteNames.excuses),
                      ),
                      if (isParent) ...[
                        const Divider(height: 24),
                        _ActionRow(
                          icon: LucideIcons.creditCard,
                          title: tr.tr('billing'),
                          subtitle: 'Estado de cuenta y pagos registrados',
                          onTap: () => context.pushNamed(RouteNames.payments),
                        ),
                      ] else if (isTeacher) ...[
                        const Divider(height: 24),
                        _ActionRow(
                          icon: LucideIcons.users,
                          title: 'Mis grupos',
                          subtitle:
                              'Consulta salones, alumnos y actividad del aula',
                          onTap: () => context.pushNamed(RouteNames.groups),
                        ),
                      ] else if (isDirector) ...[
                        const Divider(height: 24),
                        _ActionRow(
                          icon: LucideIcons.barChart3,
                          title: 'Reportes',
                          subtitle:
                              'Resumen operativo, asistencia y pendientes',
                          onTap: () => context.pushNamed(RouteNames.reports),
                        ),
                        const Divider(height: 24),
                        _ActionRow(
                          icon: LucideIcons.users,
                          title: 'Familias',
                          subtitle:
                              'Registra padres y vincúlalos con sus hijos',
                          onTap: () => context.pushNamed(RouteNames.families),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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
            const SizedBox(height: 8),
            ListTile(
              visualDensity: VisualDensity.compact,
              leading: const Icon(LucideIcons.camera),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarSource.camera),
            ),
            ListTile(
              visualDensity: VisualDensity.compact,
              leading: const Icon(LucideIcons.image),
              title: const Text('Elegir de galería'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AvatarSource.gallery),
            ),
            const SizedBox(height: 8),
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

    return CompactHeroCard(
      eyebrow: _roleLabel(user?.role),
      title: user?.fullName ?? 'Usuario',
      subtitle: tenant?.name ?? 'Institucion',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$childrenCount perfiles',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
      child: Row(
        children: [
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
                      width: 32,
                      height: 32,
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
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: context.appColor(AppColors.textSecondary),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AvatarSource { camera, gallery }

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({required this.user, required this.childrenCount});

  final UserInfo? user;
  final int childrenCount;

  @override
  Widget build(BuildContext context) {
    final linkedLabel = user?.role == UserRole.parent ? 'Familia' : 'Perfiles';
    final linkedValue = user?.role == UserRole.parent
        ? '$childrenCount vinculados'
        : '$childrenCount visibles';
    final items = [
      (
        'Rol',
        _roleLabel(user?.role),
        LucideIcons.badgeCheck,
        AppColors.primary,
      ),
      (linkedLabel, linkedValue, LucideIcons.users, AppColors.secondary),
      (
        'Contacto',
        user?.phone ?? 'Sin teléfono',
        LucideIcons.phone,
        AppColors.info,
      ),
    ];

    return Column(
      children: [
        Row(
          children: items
              .take(2)
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: item == items[1] ? 0 : 12),
                    child: _OverviewCard(item: item),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _OverviewCard(item: items[2], compact: true),
        ),
      ],
    );
  }
}

class _ChildrenSummaryCard extends StatelessWidget {
  const _ChildrenSummaryCard({required this.user, required this.children});

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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
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
            ...children
                .take(3)
                .map(
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
          color: context.appColor(AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            LBAvatar(
              placeholder: child.firstName.isNotEmpty
                  ? child.firstName[0]
                  : 'N',
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
                    style: TextStyle(
                      color: context.appColor(AppColors.textSecondary),
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
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  final dynamic tr;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
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
          _PreferenceRow(
            icon: isDarkMode ? LucideIcons.moon : LucideIcons.sun,
            iconColor: AppColors.primary,
            title: 'Tema visual',
            subtitle: isDarkMode
                ? 'Modo oscuro activado'
                : 'Modo claro activado',
            trailing: _AnimatedThemeSwitcher(
              isDarkMode: isDarkMode,
              onToggle: onToggleTheme,
            ),
          ),
          const Divider(height: 24),
          _PreferenceRow(
            icon: LucideIcons.globe,
            iconColor: AppColors.primary,
            title: tr.tr('language'),
            subtitle: 'Cambia el idioma de la experiencia',
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'es', label: Text('ES')),
              ],
              selected: {currentLocale},
              onSelectionChanged: (selection) {
                onLanguageChanged(selection.first);
              },
              style: ButtonStyle(
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -3,
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.item, this.compact = false});

  final (String, String, IconData, Color) item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LBCard(
      child: Row(
        children: [
          Container(
            width: compact ? 44 : 40,
            height: compact ? 44 : 40,
            decoration: BoxDecoration(
              color: item.$4.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.$3, color: item.$4, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$2,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 16 : 15,
                    fontWeight: FontWeight.w800,
                    color: context.appColor(AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$1,
                  style: TextStyle(
                    color: context.appColor(AppColors.textSecondary),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedThemeSwitcher extends StatelessWidget {
  const _AnimatedThemeSwitcher({
    required this.isDarkMode,
    required this.onToggle,
  });

  final bool isDarkMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 88,
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1E2633)
              : const Color(0xFFF3E3A6),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDarkMode ? 28 : 16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                    key: ValueKey(isDarkMode),
                    color: isDarkMode ? const Color(0xFF4D5B86) : AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isDarkMode ? 0 : 1,
                  child: const Icon(
                    LucideIcons.sun,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isDarkMode ? 1 : 0,
                  child: const Icon(
                    LucideIcons.moon,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.appColor(AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.appColor(AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.appColor(AppColors.textSecondary),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(child: trailing),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    this.icon,
    this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? leading;
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
          leading ??
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.appColor(AppColors.textSecondary),
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
