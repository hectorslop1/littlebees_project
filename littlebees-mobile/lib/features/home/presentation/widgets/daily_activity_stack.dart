import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/utils/resolve_image_url.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_radii.dart';
import '../../../../design_system/theme/app_shadows.dart';
import '../../domain/timeline_event.dart';

class ExpandableActivitySection extends StatefulWidget {
  const ExpandableActivitySection({
    super.key,
    required this.events,
    this.initiallyExpanded = false,
  });

  final List<TimelineEvent> events;
  final bool initiallyExpanded;

  @override
  State<ExpandableActivitySection> createState() =>
      _ExpandableActivitySectionState();
}

class _ExpandableActivitySectionState extends State<ExpandableActivitySection> {
  late bool _isExpanded;
  final GlobalKey _timelineContentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant ExpandableActivitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const SizedBox.shrink();
    }

    final latestEvent = widget.events.first;
    final olderEvents = widget.events.skip(1).toList(growable: false);
    final canExpand = olderEvents.isNotEmpty;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LatestActivityCard(
            event: latestEvent,
            isExpanded: _isExpanded,
            canExpand: canExpand,
            onToggle: canExpand ? _toggleExpanded : null,
            onOpenDetail: () => _openDetail(context, latestEvent),
          ),
          if (olderEvents.isNotEmpty)
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                heightFactor: _isExpanded ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_isExpanded,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    opacity: _isExpanded ? 1 : 0,
                    child: Padding(
                      key: _timelineContentKey,
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TimelineHeader(count: olderEvents.length),
                          const SizedBox(height: 12),
                          _buildTimeline(context, olderEvents),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<TimelineEvent> events) {
    if (widget.events.length < 10) {
      return Column(
        children: [
          for (var i = 0; i < events.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == events.length - 1 ? 0 : 12),
              child: _buildAnimatedTimelineItem(
                context,
                event: events[i],
                index: i,
                isLast: i == events.length - 1,
              ),
            ),
        ],
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: index == events.length - 1 ? 0 : 12),
        child: _buildAnimatedTimelineItem(
          context,
          event: events[index],
          index: index,
          isLast: index == events.length - 1,
        ),
      ),
    );
  }

  Widget _buildAnimatedTimelineItem(
    BuildContext context, {
    required TimelineEvent event,
    required int index,
    required bool isLast,
  }) {
    return _TimelineActivityItem(
      event: event,
      isLast: isLast,
      onTap: () => _openDetail(context, event),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 32 * index),
      duration: 220.ms,
    ).slideY(
      begin: 0.05,
      end: 0,
      delay: Duration(milliseconds: 32 * index),
      duration: 220.ms,
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      final scrollPosition = Scrollable.maybeOf(context)?.position;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 140), () {
          if (!mounted || scrollPosition == null) {
            return;
          }

          final renderObject =
              _timelineContentKey.currentContext?.findRenderObject();
          if (renderObject == null) {
            return;
          }

          scrollPosition.ensureVisible(
            renderObject,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            alignment: 0.9,
          );
        });
      });
    }
  }

  void _openDetail(BuildContext context, TimelineEvent event) {
    final resolvedPhotoUrl = _resolvedPhotoUrl(event);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ActivityDetailScreen(
          event: event,
          imageUrl: resolvedPhotoUrl,
          heroTag: resolvedPhotoUrl == null ? null : _heroTagForEvent(event),
        ),
      ),
    );
  }
}

@Deprecated('Use ExpandableActivitySection instead.')
class DailyActivityStack extends StatelessWidget {
  const DailyActivityStack({
    super.key,
    required this.events,
    this.initiallyExpanded = false,
  });

  final List<TimelineEvent> events;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return ExpandableActivitySection(
      events: events,
      initiallyExpanded: initiallyExpanded,
    );
  }
}

class _LatestActivityCard extends StatelessWidget {
  const _LatestActivityCard({
    required this.event,
    required this.isExpanded,
    required this.canExpand,
    required this.onToggle,
    required this.onOpenDetail,
  });

  final TimelineEvent event;
  final bool isExpanded;
  final bool canExpand;
  final VoidCallback? onToggle;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolvedPhotoUrl(event);
    final surface = context.appColor(AppColors.surface);
    final border = context.appColor(AppColors.border);
    final heroTag = imageUrl == null ? null : _heroTagForEvent(event);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadii.borderRadiusLg,
          border: Border.all(color: border),
          boxShadow: [AppShadows.shadowLg],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 164),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: AppRadii.borderRadiusMd,
                      onTap: onToggle ?? onOpenDetail,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 128),
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _ActivityTypeChip(event: event)),
                                if (canExpand)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: context.appColor(
                                        AppColors.surfaceVariant,
                                      ),
                                      borderRadius: AppRadii.borderRadiusFull,
                                    ),
                                    child: AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: Icon(
                                        LucideIcons.chevronDown,
                                        size: 16,
                                        color: context.appColor(
                                          AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _activityMessage(event),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.appColor(AppColors.textPrimary),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MetaPill(
                                  icon: LucideIcons.calendarDays,
                                  label: _formatDate(context, event.timestamp),
                                ),
                                _MetaPill(
                                  icon: LucideIcons.clock3,
                                  label: _formatTime(context, event.timestamp),
                                ),
                                if ((event.caregiverName ?? '').trim().isNotEmpty)
                                  _MetaPill(
                                    icon: LucideIcons.user,
                                    label: event.caregiverName!,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _ActivityImagePreview(
                  imageUrl: imageUrl,
                  heroTag: heroTag,
                  icon: _iconForType(event.type),
                  color: _accentForType(event.type),
                  width: 118,
                  height: 128,
                  onTap: onOpenDetail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            count == 1 ? 'Actividad anterior' : 'Actividades anteriores',
            style: TextStyle(
              color: context.appColor(AppColors.textPrimary),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.appColor(AppColors.primarySurface),
              borderRadius: AppRadii.borderRadiusFull,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineActivityItem extends StatelessWidget {
  const _TimelineActivityItem({
    required this.event,
    required this.isLast,
    required this.onTap,
  });

  final TimelineEvent event;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolvedPhotoUrl(event);
    final accent = _accentForType(event.type);

    return SizedBox(
      height: 108,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineRail(color: accent, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.surface),
                  borderRadius: AppRadii.borderRadiusMd,
                  border: Border.all(color: context.appColor(AppColors.border)),
                  boxShadow: [AppShadows.shadowSm],
                ),
                child: InkWell(
                  borderRadius: AppRadii.borderRadiusMd,
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _activityChipLabel(context, event),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.appColor(
                                          AppColors.textPrimary,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatShortTimestamp(
                                      context,
                                      event.timestamp,
                                    ),
                                    style: TextStyle(
                                      color: context.appColor(
                                        AppColors.textSecondary,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  _activityMessage(event),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.appColor(
                                      AppColors.textSecondary,
                                    ),
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _ActivityImagePreview(
                          imageUrl: imageUrl,
                          heroTag: imageUrl == null ? null : _heroTagForEvent(event),
                          icon: _iconForType(event.type),
                          color: accent,
                          width: 74,
                          height: 82,
                          onTap: onTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.color, required this.isLast});

  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            bottom: isLast ? 38 : 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: color.withAlpha(72),
                borderRadius: AppRadii.borderRadiusFull,
              ),
            ),
          ),
          Positioned(
            top: 16,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: context.appColor(AppColors.surface),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityImagePreview extends StatelessWidget {
  const _ActivityImagePreview({
    required this.imageUrl,
    required this.heroTag,
    required this.icon,
    required this.color,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final String? imageUrl;
  final String? heroTag;
  final IconData icon;
  final Color color;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _ActivityPlaceholder(color: color, icon: icon),
              )
            : _ActivityPlaceholder(color: color, icon: icon),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: heroTag == null ? child : Hero(tag: heroTag!, child: child),
    );
  }
}

class _ActivityPlaceholder extends StatelessWidget {
  const _ActivityPlaceholder({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(58), color.withAlpha(18)],
        ),
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.appColor(AppColors.surface).withAlpha(
              context.isDark ? 230 : 190,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _ActivityTypeChip extends StatelessWidget {
  const _ActivityTypeChip({required this.event});

  final TimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(event.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withAlpha(24),
        borderRadius: AppRadii.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForType(event.type), color: accent, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _activityChipLabel(context, event),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surfaceVariant),
        borderRadius: AppRadii.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: context.appColor(AppColors.textSecondary),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.appColor(AppColors.textSecondary),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDetailScreen extends StatelessWidget {
  const _ActivityDetailScreen({
    required this.event,
    required this.imageUrl,
    required this.heroTag,
  });

  final TimelineEvent event;
  final String? imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(event.type);

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.appColor(AppColors.textPrimary),
        title: Text(_activityChipLabel(context, event)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.appColor(AppColors.surface),
                borderRadius: AppRadii.borderRadiusLg,
                boxShadow: [AppShadows.shadowLg],
              ),
              child: ClipRRect(
                borderRadius: AppRadii.borderRadiusLg,
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Hero(
                          tag: heroTag!,
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _ActivityPlaceholder(
                                  color: accent,
                                  icon: _iconForType(event.type),
                                ),
                          ),
                        )
                      : _ActivityPlaceholder(
                          color: accent,
                          icon: _iconForType(event.type),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaPill(
                  icon: LucideIcons.calendarDays,
                  label: _formatDate(context, event.timestamp),
                ),
                _MetaPill(
                  icon: LucideIcons.clock3,
                  label: _formatTime(context, event.timestamp),
                ),
                if ((event.caregiverName ?? '').trim().isNotEmpty)
                  _MetaPill(
                    icon: LucideIcons.user,
                    label: event.caregiverName!,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              event.title,
              style: TextStyle(
                color: context.appColor(AppColors.textPrimary),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _activityDetailMessage(event),
              style: TextStyle(
                color: context.appColor(AppColors.textSecondary),
                fontSize: 16,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _heroTagForEvent(TimelineEvent event) => 'home-activity-${event.id}';

String? _resolvedPhotoUrl(TimelineEvent event) {
  if (event.photoUrls?.isNotEmpty != true) {
    return null;
  }

  return resolveImageUrl(event.photoUrls!.first);
}

String _activityMessage(TimelineEvent event) {
  final description = event.description?.trim();
  if (description != null && description.isNotEmpty) {
    return description;
  }

  return event.title.trim().isEmpty ? _fallbackMessageForType(event.type) : event.title;
}

String _activityDetailMessage(TimelineEvent event) {
  final description = event.description?.trim();
  final title = event.title.trim();

  if (description != null && description.isNotEmpty && description != title) {
    return description;
  }

  return title.isEmpty ? _fallbackMessageForType(event.type) : title;
}

String _fallbackMessageForType(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.checkIn:
      return 'Registro de entrada del dia';
    case TimelineEventType.checkOut:
      return 'Registro de salida del dia';
    case TimelineEventType.meal:
      return 'Se registro un momento de comida.';
    case TimelineEventType.nap:
      return 'Se registro un periodo de descanso.';
    case TimelineEventType.photo:
      return 'Nueva foto compartida.';
    case TimelineEventType.note:
      return 'Nueva observacion del dia.';
    case TimelineEventType.activity:
      return 'Nueva actividad compartida.';
    case TimelineEventType.medication:
      return 'Se registro una medicacion.';
    case TimelineEventType.milestone:
      return 'Nuevo logro destacado.';
  }
}

String _formatDate(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.MMMMd(locale).format(dateTime);
}

String _formatTime(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.jm(locale).format(dateTime);
}

String _formatShortTimestamp(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.MMMd(locale).add_jm().format(dateTime);
}

String _activityChipLabel(BuildContext context, TimelineEvent event) {
  final title = event.title.trim();
  if (title.isNotEmpty && title.length <= 28) {
    return title;
  }

  return _typeLabel(context, event.type);
}

String _typeLabel(BuildContext context, TimelineEventType type) {
  final isSpanish = Localizations.localeOf(context).languageCode == 'es';
  switch (type) {
    case TimelineEventType.checkIn:
      return isSpanish ? 'Entrada' : 'Check-in';
    case TimelineEventType.checkOut:
      return isSpanish ? 'Salida' : 'Check-out';
    case TimelineEventType.meal:
      return isSpanish ? 'Comida' : 'Meal';
    case TimelineEventType.nap:
      return isSpanish ? 'Siesta' : 'Nap';
    case TimelineEventType.photo:
      return isSpanish ? 'Foto' : 'Photo';
    case TimelineEventType.note:
      return isSpanish ? 'Nota' : 'Note';
    case TimelineEventType.activity:
      return isSpanish ? 'Actividad' : 'Activity';
    case TimelineEventType.medication:
      return isSpanish ? 'Medicacion' : 'Medication';
    case TimelineEventType.milestone:
      return isSpanish ? 'Logro' : 'Milestone';
  }
}

IconData _iconForType(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.checkIn:
      return LucideIcons.badgeCheck;
    case TimelineEventType.checkOut:
      return LucideIcons.logOut;
    case TimelineEventType.meal:
      return LucideIcons.utensils;
    case TimelineEventType.nap:
      return LucideIcons.moon;
    case TimelineEventType.photo:
      return LucideIcons.camera;
    case TimelineEventType.note:
      return LucideIcons.fileText;
    case TimelineEventType.activity:
      return LucideIcons.sparkles;
    case TimelineEventType.medication:
      return LucideIcons.pill;
    case TimelineEventType.milestone:
      return LucideIcons.star;
  }
}

Color _accentForType(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.checkIn:
      return AppColors.success;
    case TimelineEventType.checkOut:
      return AppColors.error;
    case TimelineEventType.meal:
      return AppColors.warning;
    case TimelineEventType.nap:
      return AppColors.info;
    case TimelineEventType.photo:
      return AppColors.primary;
    case TimelineEventType.note:
      return AppColors.secondary;
    case TimelineEventType.activity:
      return AppColors.primary;
    case TimelineEventType.medication:
      return AppColors.error;
    case TimelineEventType.milestone:
      return AppColors.warning;
  }
}
