import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../groups/application/groups_provider.dart';

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

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir galería: $e')));
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir cámara: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Actividad'), elevation: 0),
      body: SafeArea(
        child: groupsAsync.when(
          data: (groups) {
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Selection
                  const Text(
                    'Selecciona el Grupo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    decoration: InputDecoration(
                      hintText: 'Selecciona un grupo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
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
                        _selectedChildId = null; // Reset child selection
                      });
                    },
                  ),

                  if (_selectedGroupId != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Selecciona el Niño',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer(
                      builder: (context, ref, _) {
                        final groupDetailAsync = ref.watch(
                          groupByIdProvider(_selectedGroupId!),
                        );
                        return groupDetailAsync.when(
                          data: (groupDetail) {
                            final children = groupDetail.children ?? [];
                            if (children.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'No hay niños asignados a este grupo',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return DropdownButtonFormField<String>(
                              value: _selectedChildId,
                              decoration: InputDecoration(
                                hintText: 'Selecciona un niño',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceVariant,
                              ),
                              items: children.map((child) {
                                final id = child['id'] as String;
                                final name =
                                    '${child['firstName'] ?? ''} ${child['lastName'] ?? ''}'
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
                          error: (e, _) => Text(
                            'Error al cargar niños: $e',
                            style: TextStyle(color: AppColors.error),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Tipo de Actividad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _activityTypes.map((type) {
                      final isSelected = _selectedActivityType == type['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedActivityType = type['id'] as String;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Notas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe la actividad...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Fotos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _takePicture,
                          icon: const Icon(LucideIcons.camera),
                          label: const Text('Tomar Foto'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
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
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.surfaceVariant,
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.image),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.x,
                                        size: 16,
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

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedGroupId != null &&
                              _selectedActivityType != null
                          ? () {
                              // TODO: Implement save activity
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funcionalidad de guardar actividad pendiente de implementar',
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'Guardar Actividad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.alertCircle, size: 64, color: AppColors.error),
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
      ),
    );
  }
}
