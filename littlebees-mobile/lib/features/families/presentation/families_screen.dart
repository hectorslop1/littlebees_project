import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../data/families_repository.dart';
import '../domain/family_management_models.dart';

final familiesRepositoryProvider = Provider<FamiliesRepository>((ref) {
  return FamiliesRepository();
});

class FamiliesScreen extends ConsumerStatefulWidget {
  const FamiliesScreen({super.key});

  @override
  ConsumerState<FamiliesScreen> createState() => _FamiliesScreenState();
}

class _FamiliesScreenState extends ConsumerState<FamiliesScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<ManagedParentUser> _parents = const [];
  List<ParentChildOption> _children = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repository = ref.read(familiesRepositoryProvider);
      final results = await Future.wait([
        repository.getParents(),
        repository.getChildren(),
      ]);
      if (!mounted) return;
      setState(() {
        _parents = results[0] as List<ManagedParentUser>;
        _children = results[1] as List<ParentChildOption>;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible cargar familias: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCreateParentSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateParentSheet(
        children: _children,
        isSubmitting: _isSubmitting,
        onSubmit: _createParent,
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  Future<void> _createParent(_CreateParentRequest request) async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final repository = ref.read(familiesRepositoryProvider);
      final parent = await repository.createParent(
        firstName: request.firstName,
        lastName: request.lastName,
        email: request.email,
        password: request.password,
        phone: request.phone,
      );

      for (var index = 0; index < request.childIds.length; index++) {
        await repository.assignParentToChild(
          childId: request.childIds[index],
          userId: parent.id,
          relationship: request.relationship,
          isPrimary: index == 0 ? request.isPrimary : false,
          canPickup: request.canPickup,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${parent.fullName} fue registrado y vinculado correctamente',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible registrar a la familia: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Familias'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _openCreateParentSheet,
            icon: const Icon(LucideIcons.userPlus2),
            tooltip: 'Registrar familia',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8EBC8), Color(0xFFE7F0FB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(190),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Dirección escolar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Alta de familias y vínculos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Registra padres o tutores que podrán iniciar sesión y asígnales hijos desde un solo flujo.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _FamilyMetric(
                                  label: 'Padres',
                                  value: '${_parents.length}',
                                  icon: LucideIcons.users,
                                  tint: AppColors.primarySurface,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FamilyMetric(
                                  label: 'Alumnos',
                                  value: '${_children.length}',
                                  icon: LucideIcons.baby,
                                  tint: AppColors.secondarySurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Padres y tutores',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _openCreateParentSheet,
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Registrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_parents.isEmpty)
                      const LBCard(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Aún no hay padres registrados desde móvil. Usa “Registrar” para dar de alta la primera familia.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._parents.map(
                        (parent) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LBCard(
                            child: Row(
                              children: [
                                LBAvatar(
                                  imageUrl: parent.avatarUrl,
                                  placeholder: parent.fullName.isNotEmpty
                                      ? parent.fullName.characters.first
                                      : 'P',
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        parent.fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        parent.email,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if ((parent.phone ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          parent.phone!,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FamilyMetric extends StatelessWidget {
  const _FamilyMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.textPrimary, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CreateParentRequest {
  const _CreateParentRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.childIds,
    required this.relationship,
    required this.isPrimary,
    required this.canPickup,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final List<String> childIds;
  final String relationship;
  final bool isPrimary;
  final bool canPickup;
}

class _CreateParentSheet extends StatefulWidget {
  const _CreateParentSheet({
    required this.children,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final List<ParentChildOption> children;
  final bool isSubmitting;
  final Future<void> Function(_CreateParentRequest request) onSubmit;

  @override
  State<_CreateParentSheet> createState() => _CreateParentSheetState();
}

class _CreateParentSheetState extends State<_CreateParentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController(text: 'Padre/Madre');
  final Set<String> _selectedChildIds = {};
  bool _isPrimary = true;
  bool _canPickup = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un hijo')),
      );
      return;
    }

    await widget.onSubmit(
      _CreateParentRequest(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        childIds: _selectedChildIds.toList(),
        relationship: _relationshipController.text.trim(),
        isPrimary: _isPrimary,
        canPickup: _canPickup,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            blurRadius: 32,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Registrar familia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crea el acceso del padre o tutor y asígnale hijos desde este mismo flujo.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                _InputField(controller: _firstNameController, label: 'Nombre'),
                const SizedBox(height: 12),
                _InputField(
                  controller: _lastNameController,
                  label: 'Apellidos',
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: _passwordController,
                  label: 'Contraseña temporal',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  keyboardType: TextInputType.phone,
                  required: false,
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: _relationshipController,
                  label: 'Relación con el niño',
                ),
                const SizedBox(height: 18),
                const Text(
                  'Asignar hijos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.children.map((child) {
                    final selected = _selectedChildIds.contains(child.id);
                    return FilterChip(
                      selected: selected,
                      avatar: LBAvatar(
                        imageUrl: child.photoUrl,
                        placeholder: child.fullName.isNotEmpty
                            ? child.fullName.characters.first
                            : 'N',
                        size: LBAvatarSize.small,
                      ),
                      label: Text(child.fullName),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedChildIds.add(child.id);
                          } else {
                            _selectedChildIds.remove(child.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SwitchListTile.adaptive(
                  value: _isPrimary,
                  onChanged: (value) => setState(() => _isPrimary = value),
                  title: const Text('Marcar como tutor principal'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile.adaptive(
                  value: _canPickup,
                  onChanged: (value) => setState(() => _canPickup = value),
                  title: const Text('Puede recoger al niño'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.isSubmitting ? null : _submit,
                    child: widget.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrar familia'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.required = true,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (!required) return null;
        if ((value ?? '').trim().isEmpty) {
          return 'Campo requerido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
