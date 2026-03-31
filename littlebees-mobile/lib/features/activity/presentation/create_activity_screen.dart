import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/services/file_upload_service.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/compact_layout.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../child_profile/application/child_profile_provider.dart';
import '../../groups/application/groups_provider.dart';
import '../../groups/domain/group_model.dart';
import '../../home/application/home_providers.dart';
import '../../register_activity/application/register_activity_provider.dart';
import '../application/activity_controller.dart';

class CreateActivityScreen extends ConsumerStatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  ConsumerState<CreateActivityScreen> createState() =>
      _CreateActivityScreenState();
}

class _CreateActivityScreenState extends ConsumerState<CreateActivityScreen> {
  String? _selectedGroupId;
  String? _selectedChildId;
  String? _selectedActivityType;
  final _notesController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final _picker = ImagePicker();
  final _uploadService = FileUploadService();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _activityTypes = [
    {'id': 'meal', 'label': 'Comida', 'icon': LucideIcons.utensils},
    {'id': 'nap', 'label': 'Siesta', 'icon': LucideIcons.moon},
    {'id': 'bathroom', 'label': 'Baño', 'icon': LucideIcons.droplet},
    {'id': 'play', 'label': 'Juego', 'icon': LucideIcons.gamepad2},
    {'id': 'learning', 'label': 'Aprendizaje', 'icon': LucideIcons.bookOpen},
    {'id': 'outdoor', 'label': 'Exterior', 'icon': LucideIcons.sun},
    {'id': 'art', 'label': 'Arte', 'icon': LucideIcons.palette},
    {'id': 'other', 'label': 'Otro', 'icon': LucideIcons.moreHorizontal},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _ensureSelectedGroup(List<GroupModel> groups) {
    if (_selectedGroupId != null || groups.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedGroupId != null) return;
      setState(() {
        _selectedGroupId = groups.first.id;
      });
    });
  }

  void _ensureSelectedChild(List<Map<String, dynamic>> children) {
    if (_selectedChildId != null || children.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedChildId != null) return;
      setState(() {
        _selectedChildId = children.first['id'] as String?;
      });
    });
  }

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage();
      if (images.isEmpty) return;
      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al abrir galería: $e')));
    }
  }

  Future<void> _takePicture() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      setState(() {
        _selectedImages.add(image);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al abrir cámara: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  String get _selectedActivityLabel {
    final selected = _activityTypes.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == _selectedActivityType,
      orElse: () => null,
    );
    return selected?['label'] as String? ?? 'Actividad';
  }

  String get _backendActivityType {
    switch (_selectedActivityType) {
      case 'meal':
        return 'meal';
      case 'nap':
        return 'nap';
      default:
        return 'activity';
    }
  }

  Color _activityAccent(String activityId) {
    switch (activityId) {
      case 'meal':
        return AppColors.primary;
      case 'nap':
        return AppColors.info;
      case 'bathroom':
        return AppColors.secondary;
      case 'play':
        return AppColors.warning;
      case 'learning':
        return AppColors.info;
      case 'outdoor':
        return AppColors.success;
      case 'art':
        return const Color(0xFFD78AC5);
      default:
        return AppColors.textSecondary;
    }
  }

  String _activityHelperText(String? activityId) {
    switch (activityId) {
      case 'meal':
        return 'Registra qué comió y cómo estuvo la toma.';
      case 'nap':
        return 'Anota cómo descansó y cualquier detalle importante.';
      case 'bathroom':
        return 'Documenta cambios, higiene u observaciones del baño.';
      case 'play':
        return 'Comparte juegos, interacción y energía del aula.';
      case 'learning':
        return 'Resume aprendizajes, concentración o avances del día.';
      case 'outdoor':
        return 'Cuenta qué hicieron afuera y cómo participó.';
      case 'art':
        return 'Ideal para manualidades, dibujo, música o expresión.';
      default:
        return 'Las familias verán este registro en su pantalla principal.';
    }
  }

  Future<void> _submitActivity() async {
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un grupo')));
      return;
    }

    if (_selectedChildId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un niño')));
      return;
    }

    if (_selectedActivityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de actividad')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uploadedPhotoIds = <String>[];
      for (final image in _selectedImages) {
        final result = await _uploadService.uploadActivityPhoto(
          File(image.path),
        );
        uploadedPhotoIds.add(result.fileId);
      }

      final notes = _notesController.text.trim();
      final label = _selectedActivityLabel;
      final now = DateTime.now();
      final localDate =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final localTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      await ref
          .read(registerActivityProvider.notifier)
          .quickRegister(
            childId: _selectedChildId!,
            type: _backendActivityType,
            title: label,
            description: notes.isEmpty ? label : notes,
            date: localDate,
            time: localTime,
            metadata: {
              'activityType': _selectedActivityType,
              'activityTitle': label,
              'activityDescription': notes.isEmpty ? label : notes,
              if (notes.isNotEmpty) 'notes': notes,
              if (_backendActivityType == 'meal')
                'foodEaten': notes.isEmpty ? label : notes,
              if (uploadedPhotoIds.isNotEmpty) 'photoUrls': uploadedPhotoIds,
            },
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label registrada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      ref.invalidate(photosProvider);
      ref.invalidate(activityFeedProvider);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible guardar la actividad: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar Actividad'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Listo para guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedActivityType == null
                          ? 'Completa grupo, alumno y tipo.'
                          : 'Se guardara en la bitacora del nino.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(190),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitActivity,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.checkCircle2, size: 18),
                  label: Text(
                    _isSubmitting ? 'Guardando...' : 'Guardar',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            groupsAsync.when(
              data: (groups) {
                _ensureSelectedGroup(groups);

                if (groups.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes grupos asignados',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompactHeroCard(
                        eyebrow: 'Bitacora del aula',
                        eyebrowIcon: LucideIcons.sparkles,
                        title: 'Comparte el dia en tiempo real',
                        subtitle:
                            'Cada registro alimenta la experiencia del padre en Inicio. Manten la bitacora viva con momentos claros y utiles.',
                        child: Row(
                          children: [
                            Expanded(
                              child: CompactMetricTile(
                                icon: LucideIcons.layoutGrid,
                                label: 'Grupos',
                                value: '${groups.length}',
                                accent: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CompactMetricTile(
                                icon: LucideIcons.image,
                                label: 'Fotos',
                                value: '${_selectedImages.length}',
                                accent: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CompactSectionCard(
                        title: 'Grupo y niño',
                        subtitle:
                            'Elige primero el salón y después al alumno para registrar correctamente la actividad.',
                        icon: LucideIcons.users,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGroupId,
                              decoration: InputDecoration(
                                labelText: 'Grupo',
                                hintText: 'Selecciona un grupo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: groups.map((group) {
                                return DropdownMenuItem(
                                  value: group.id,
                                  child: Text(group.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGroupId = value;
                                  _selectedChildId = null;
                                });
                              },
                            ),
                            if (_selectedGroupId != null) ...[
                              const SizedBox(height: 12),
                              Consumer(
                                builder: (context, ref, _) {
                                  final groupDetailAsync = ref.watch(
                                    groupByIdProvider(_selectedGroupId!),
                                  );
                                  final knownChildren =
                                      ref
                                          .watch(myChildrenProvider)
                                          .valueOrNull ??
                                      const [];
                                  final childPhotoIndex = {
                                    for (final child in knownChildren)
                                      child.id: child.photoUrl,
                                  };

                                  return groupDetailAsync.when(
                                    data: (groupDetail) {
                                      final children =
                                          groupDetail.children ?? [];
                                      _ensureSelectedChild(children);

                                      if (children.isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                          child: Text(
                                            'No hay niños asignados a este grupo todavía.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        );
                                      }

                                      final selectedChild =
                                          _selectedChildId == null
                                          ? null
                                          : children
                                                .cast<Map<String, dynamic>?>()
                                                .firstWhere(
                                                  (child) =>
                                                      child?['id'] ==
                                                      _selectedChildId,
                                                  orElse: () => null,
                                                );
                                      final selectedChildName =
                                          selectedChild == null
                                          ? 'Selecciona un niño'
                                          : '${selectedChild['firstName'] ?? ''} ${selectedChild['lastName'] ?? ''}'
                                                .trim();
                                      final selectedChildId =
                                          selectedChild?['id'] as String?;
                                      final selectedChildPhotoUrl =
                                          (selectedChild?['photoUrl']
                                                  as String?) ??
                                          (selectedChildId != null
                                              ? childPhotoIndex[selectedChildId]
                                              : null);

                                      return Column(
                                        children: [
                                          DropdownButtonFormField<String>(
                                            initialValue: _selectedChildId,
                                            decoration: InputDecoration(
                                              labelText: 'Niño',
                                              hintText: 'Selecciona un niño',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            items: children.map((child) {
                                              final childMap =
                                                  Map<String, dynamic>.from(
                                                    child,
                                                  );
                                              final id =
                                                  childMap['id'] as String;
                                              final name =
                                                  '${childMap['firstName'] ?? ''} ${childMap['lastName'] ?? ''}'
                                                      .trim();
                                              return DropdownMenuItem(
                                                value: id,
                                                child: Text(name),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedChildId = value;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9FBFD),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Consumer(
                                                  builder: (context, ref, _) {
                                                    final profilePhotoUrl =
                                                        selectedChildId == null
                                                        ? null
                                                        : ref
                                                              .watch(
                                                                childProfileProvider(
                                                                  selectedChildId,
                                                                ),
                                                              )
                                                              .valueOrNull
                                                              ?.photoUrl;

                                                    return LBAvatar(
                                                      imageUrl:
                                                          profilePhotoUrl ??
                                                          selectedChildPhotoUrl,
                                                      placeholder:
                                                          selectedChildName,
                                                      size: LBAvatarSize.large,
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        selectedChildName,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Grupo ${groupDetail.displayName}',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    loading: () => const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    error: (error, _) => Text(
                                      'Error al cargar niños: $error',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CompactSectionCard(
                        title: 'Tipo de actividad',
                        subtitle: _activityHelperText(_selectedActivityType),
                        icon: LucideIcons.sparkles,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activityTypes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 2.3,
                              ),
                          itemBuilder: (context, index) {
                            final type = _activityTypes[index];
                            final id = type['id'] as String;
                            final isSelected = _selectedActivityType == id;
                            final accent = _activityAccent(id);

                            return CompactChoiceTile(
                              icon: type['icon'] as IconData,
                              label: type['label'] as String,
                              selected: isSelected,
                              accent: accent,
                              onTap: () {
                                setState(() {
                                  _selectedActivityType = id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      CompactSectionCard(
                        title: 'Notas para familias',
                        subtitle:
                            'Escribe un resumen breve, claro y útil de lo que pasó.',
                        icon: LucideIcons.fileText,
                        child: TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Ej. Santiago se durmió media hora y despertó de muy buen ánimo.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CompactSectionCard(
                        title: 'Fotos del momento',
                        subtitle:
                            'Adjunta evidencia visual para enriquecer la bitácora del día.',
                        icon: LucideIcons.camera,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _takePicture,
                                    icon: const Icon(LucideIcons.camera),
                                    label: const Text('Tomar foto'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primarySurface,
                                      foregroundColor: AppColors.primary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(LucideIcons.image),
                                    label: const Text('Galería'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: BorderSide(color: AppColors.border),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedImages.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 92,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Image.file(
                                              File(_selectedImages[index].path),
                                              width: 92,
                                              height: 92,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black87,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  LucideIcons.x,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (_isSubmitting)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withAlpha(40),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Guardando actividad...',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
