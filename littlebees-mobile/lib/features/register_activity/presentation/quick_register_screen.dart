import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../application/register_activity_provider.dart';
import '../../../core/services/image_service.dart';
import '../../../core/services/file_upload_service.dart';
import 'widgets/photo_capture_widget.dart';

enum ActivityType { checkIn, meal, nap, activity, checkOut }

class QuickRegisterScreen extends ConsumerStatefulWidget {
  final String childId;
  final String childName;
  final ActivityType? defaultType;

  const QuickRegisterScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.defaultType,
  });

  @override
  ConsumerState<QuickRegisterScreen> createState() =>
      _QuickRegisterScreenState();
}

class _QuickRegisterScreenState extends ConsumerState<QuickRegisterScreen> {
  ActivityType _selectedType = ActivityType.checkIn;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _foodEatenController = TextEditingController();
  final TextEditingController _napDurationController = TextEditingController();
  final TextEditingController _activityDescController = TextEditingController();
  final ImageService _imageService = ImageService();
  final FileUploadService _uploadService = FileUploadService();

  File? _capturedPhoto;
  String? _photoUrl;
  String? _mood;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.defaultType != null) {
      _selectedType = widget.defaultType!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _foodEatenController.dispose();
    _napDurationController.dispose();
    _activityDescController.dispose();
    super.dispose();
  }

  String _getActivityLabel(ActivityType type) {
    switch (type) {
      case ActivityType.checkIn:
        return 'Entrada';
      case ActivityType.meal:
        return 'Comida';
      case ActivityType.nap:
        return 'Siesta';
      case ActivityType.activity:
        return 'Actividad';
      case ActivityType.checkOut:
        return 'Salida';
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.checkIn:
        return LucideIcons.logIn;
      case ActivityType.meal:
        return LucideIcons.utensils;
      case ActivityType.nap:
        return LucideIcons.moon;
      case ActivityType.activity:
        return LucideIcons.activity;
      case ActivityType.checkOut:
        return LucideIcons.logOut;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.checkIn:
        return Colors.green;
      case ActivityType.meal:
        return Colors.orange;
      case ActivityType.nap:
        return Colors.blue;
      case ActivityType.activity:
        return Colors.purple;
      case ActivityType.checkOut:
        return Colors.red;
    }
  }

  bool _needsPhoto() {
    return _selectedType == ActivityType.checkIn ||
        _selectedType == ActivityType.checkOut;
  }

  Future<void> _handleCapturePhoto() async {
    try {
      final photo = await _imageService.capturePhoto();

      if (photo == null) return;

      // Validar tamaño
      if (!_imageService.validateFileSize(photo)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La foto es demasiado grande. Máximo 10MB.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _capturedPhoto = photo;
        _isUploadingPhoto = true;
        _uploadProgress = 0.0;
      });

      // Subir foto al servidor
      final result = await _uploadService.uploadCheckInOutPhoto(photo);

      setState(() {
        _photoUrl = result.fileId;
        _isUploadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto subida exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingPhoto = false;
        _capturedPhoto = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(registerActivityProvider.notifier);

      switch (_selectedType) {
        case ActivityType.checkIn:
          await notifier.registerCheckIn(
            childId: widget.childId,
            photoUrl: _photoUrl,
            mood: _mood,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );
          break;

        case ActivityType.checkOut:
          await notifier.registerCheckOut(
            childId: widget.childId,
            photoUrl: _photoUrl,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );
          break;

        case ActivityType.meal:
          if (_foodEatenController.text.isEmpty) {
            throw Exception('Por favor indica qué comió el niño');
          }
          await notifier.registerMeal(
            childId: widget.childId,
            foodEaten: _foodEatenController.text,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );
          break;

        case ActivityType.nap:
          final duration = int.tryParse(_napDurationController.text);
          if (duration == null || duration <= 0) {
            throw Exception(
              'Por favor indica la duración de la siesta en minutos',
            );
          }
          await notifier.registerNap(
            childId: widget.childId,
            durationMinutes: duration,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );
          break;

        case ActivityType.activity:
          if (_activityDescController.text.isEmpty) {
            throw Exception('Por favor describe la actividad');
          }
          await notifier.registerActivity(
            childId: widget.childId,
            activityDescription: _activityDescController.text,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getActivityLabel(_selectedType)} registrada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro Rápido'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del niño
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        widget.childName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.childName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Registrar actividad del día',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selector de tipo de actividad
            Text(
              'Tipo de actividad',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityType.values.map((type) {
                final isSelected = _selectedType == type;
                final color = _getActivityColor(type);

                return InkWell(
                  onTap: () => setState(() => _selectedType = type),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: isSelected ? color : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getActivityIcon(type),
                          size: 20,
                          color: isSelected ? color : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getActivityLabel(type),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? color : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Foto (para entrada/salida)
            if (_needsPhoto()) ...[
              Text(
                'Foto de ${_selectedType == ActivityType.checkIn ? "entrada" : "salida"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              PhotoCaptureWidget(
                photo: _capturedPhoto,
                isLoading: _isUploadingPhoto,
                onCapture: _handleCapturePhoto,
                onRemove: () => setState(() {
                  _capturedPhoto = null;
                  _photoUrl = null;
                }),
                label:
                    'Toca para tomar foto ${_selectedType == ActivityType.checkIn ? "de entrada" : "de salida"}',
              ),
              if (_isUploadingPhoto) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 4),
                Text(
                  'Subiendo foto... ${(_uploadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],

            // Estado de ánimo (solo para entrada)
            if (_selectedType == ActivityType.checkIn) ...[
              Text(
                'Estado de ánimo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildMoodChip('😊', 'Feliz', 'happy'),
                  _buildMoodChip('😌', 'Tranquilo', 'calm'),
                  _buildMoodChip('😢', 'Triste', 'sad'),
                  _buildMoodChip('😴', 'Cansado', 'tired'),
                  _buildMoodChip('🤩', 'Emocionado', 'excited'),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Comida consumida
            if (_selectedType == ActivityType.meal) ...[
              Text(
                '¿Qué comió?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _foodEatenController,
                decoration: InputDecoration(
                  hintText: 'Ej: Todo, La mitad, Solo la fruta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Duración de siesta
            if (_selectedType == ActivityType.nap) ...[
              Text(
                'Duración (minutos)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _napDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej: 60',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Descripción de actividad
            if (_selectedType == ActivityType.activity) ...[
              Text(
                'Descripción de la actividad',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _activityDescController,
                decoration: InputDecoration(
                  hintText: 'Ej: Pintura, Juego libre, Música',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Notas adicionales
            Text(
              'Notas adicionales (opcional)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Observaciones generales...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón de registro
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActivityColor(_selectedType),
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
                        'Registrar ${_getActivityLabel(_selectedType)}',
                        style: const TextStyle(
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
  }

  Widget _buildMoodChip(String emoji, String label, String value) {
    final isSelected = _mood == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _mood = selected ? value : null);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
