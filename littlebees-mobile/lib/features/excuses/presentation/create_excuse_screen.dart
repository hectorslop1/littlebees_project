import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
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

  String? _selectedChildId;
  ExcuseType _selectedType = ExcuseType.sick;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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

      await notifier.createExcuse(
        childId: _selectedChildId!,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        date: _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Justificante creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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
                    // Selector de niño
                    Text(
                      'Niño',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedChildId,
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
                          child: Text('${child.firstName} ${child.lastName}'),
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
                    const SizedBox(height: 24),

                    // Tipo de justificante
                    Text(
                      'Tipo de justificante',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Fecha
                    Text(
                      'Fecha',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título
                    Text(
                      'Título',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Consulta médica',
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
                    const SizedBox(height: 24),

                    // Descripción
                    Text(
                      'Descripción (opcional)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Detalles adicionales...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de envío
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
                            : const Text(
                                'Enviar Justificante',
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
          loading: () => const Center(child: CircularProgressIndicator()),
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
      case ExcuseType.other:
        return 'Otro';
    }
  }
}
