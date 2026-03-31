import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/image_service.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_loading_state.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../routing/route_names.dart';
import '../application/excuses_provider.dart';
import '../../../shared/enums/enums.dart';
import '../../home/application/home_providers.dart';

class CreateExcuseScreen extends ConsumerStatefulWidget {
  const CreateExcuseScreen({super.key});

  @override
  ConsumerState<CreateExcuseScreen> createState() => _CreateExcuseScreenState();
}

class _CreateExcuseScreenState extends ConsumerState<CreateExcuseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImageService _imageService = ImageService();
  final List<_SelectedAttachment> _attachments = [];

  String? _selectedChildId;
  ExcuseType _selectedType = ExcuseType.sick;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _loadingLabel;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un niño'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(excusesNotifierProvider.notifier);
      final fileUploadService = ref.read(fileUploadServiceProvider);
      final attachmentIds = <String>[];

      if (_attachments.isNotEmpty) {
        for (var index = 0; index < _attachments.length; index++) {
          final attachment = _attachments[index];
          if (!mounted) return;
          setState(() {
            _loadingLabel =
                'Subiendo foto ${index + 1} de ${_attachments.length}';
          });

          final uploaded = await fileUploadService.uploadFile(
            file: attachment.file,
            purpose: 'excuse_attachment',
          );
          attachmentIds.add(uploaded.fileId);
        }
      }

      if (mounted) {
        setState(() {
          _loadingLabel = 'Enviando justificante';
        });
      }

      await notifier.createExcuse(
        childId: _selectedChildId!,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        date: _selectedDate,
        attachments: attachmentIds,
      );

      if (mounted) {
        ref.invalidate(excusesListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Justificante creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.goNamed(RouteNames.excuses);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLabel = null;
        });
      }
    }
  }

  Future<void> _pickAttachment(ImageSourceOption source) async {
    if (_attachments.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Puedes adjuntar hasta 4 fotos por justificante'),
        ),
      );
      return;
    }

    try {
      final file = source == ImageSourceOption.camera
          ? await _imageService.capturePhoto()
          : await _imageService.pickFromGallery();

      if (file == null) return;

      if (!_imageService.validateFileSize(file, maxSizeMB: 10)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La imagen excede el límite de 10 MB')),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _attachments.add(
          _SelectedAttachment(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            file: file,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible seleccionar la foto: $e')),
      );
    }
  }

  Future<void> _showAttachmentOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Tomar foto'),
              subtitle: const Text('Usar la cámara del dispositivo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAttachment(ImageSourceOption.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Elegir de galería'),
              subtitle: const Text('Adjuntar una imagen existente'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAttachment(ImageSourceOption.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Justificante'), elevation: 0),
      body: SafeArea(
        child: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return Center(
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
                      'No tienes hijos registrados',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LBCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  LucideIcons.fileCheck2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Comparte el justificante con la escuela',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'La directora podrá aprobarlo o rechazarlo y la maestra verá su estatus actualizado.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LBCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alumno y fecha',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Niño',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedChildId,
                            decoration: InputDecoration(
                              hintText: 'Selecciona un niño',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(LucideIcons.baby),
                            ),
                            items: children.map((child) {
                              return DropdownMenuItem(
                                value: child.id,
                                child: Text(
                                  '${child.firstName} ${child.lastName}',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedChildId = value);
                            },
                            validator: (value) {
                              if (value == null) return 'Selecciona un niño';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Fecha del justificante',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 30),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LBCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Motivo y contexto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Motivo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ExcuseType.values.map((type) {
                              final isSelected = _selectedType == type;
                              return FilterChip(
                                label: Text(_getTypeLabel(type)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() => _selectedType = type);
                                },
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Título',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText:
                                  'Ej: Consulta médica o reposo por fiebre',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa un título';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Descripción (opcional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Agrega contexto que ayude a revisar el justificante con rapidez.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LBCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Evidencia fotográfica',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Adjunta recetas, comprobantes o fotos relacionadas. Opcional.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : _showAttachmentOptions,
                                icon: const Icon(
                                  LucideIcons.paperclip,
                                  size: 16,
                                ),
                                label: const Text('Agregar'),
                              ),
                            ],
                          ),
                          ..._buildAttachmentPreviewWidgets(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _loadingLabel ?? 'Enviar Justificante',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const LBLoadingState(layout: LBLoadingLayout.detail),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  String _getTypeLabel(ExcuseType type) {
    switch (type) {
      case ExcuseType.sick:
        return 'Enfermedad';
      case ExcuseType.medical:
        return 'Cita médica';
      case ExcuseType.family:
        return 'Asunto familiar';
      case ExcuseType.travel:
        return 'Viaje';
      case ExcuseType.lateArrival:
        return 'Retardo';
      case ExcuseType.other:
        return 'Otro';
    }
  }

  List<Widget> _buildAttachmentPreviewWidgets() {
    if (_attachments.isEmpty) {
      return const [SizedBox(height: 16), _EmptyAttachmentsCard()];
    }

    return [
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _attachments.map((attachment) {
          return _SelectedAttachmentTile(
            attachment: attachment,
            onRemove: () {
              setState(() {
                _attachments.removeWhere((item) => item.id == attachment.id);
              });
            },
          );
        }).toList(),
      ),
    ];
  }
}

enum ImageSourceOption { camera, gallery }

class _SelectedAttachment {
  _SelectedAttachment({required this.id, required this.file});

  final String id;
  final File file;
}

class _SelectedAttachmentTile extends StatelessWidget {
  const _SelectedAttachmentTile({
    required this.attachment,
    required this.onRemove,
  });

  final _SelectedAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            attachment.file,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(LucideIcons.x, size: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyAttachmentsCard extends StatelessWidget {
  const _EmptyAttachmentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: const Column(
        children: [
          Icon(LucideIcons.imagePlus, color: AppColors.primary, size: 30),
          SizedBox(height: 10),
          Text(
            'Sin fotos adjuntas',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Puedes enviar el justificante solo con texto o agregar hasta 4 fotos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
