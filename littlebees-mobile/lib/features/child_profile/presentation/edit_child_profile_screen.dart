import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/services/file_upload_service.dart';
import '../../../core/services/image_service.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../application/child_profile_provider.dart';
import '../data/child_profile_repository.dart';
import '../domain/child_profile_model.dart';

class EditChildProfileScreen extends ConsumerStatefulWidget {
  const EditChildProfileScreen({super.key, required this.profile});

  final ChildProfileModel profile;

  @override
  ConsumerState<EditChildProfileScreen> createState() =>
      _EditChildProfileScreenState();
}

class _EditChildProfileScreenState
    extends ConsumerState<EditChildProfileScreen> {
  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();
  final _fileUploadService = FileUploadService();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _importantNotesController;
  late final TextEditingController _doctorNameController;
  late final TextEditingController _doctorPhoneController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _medicationsController;

  late DateTime _dateOfBirth;
  late String _gender;
  late List<ChildPickupContact> _contacts;
  String? _bloodType;
  File? _selectedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final medical = widget.profile.medicalInfo;
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _importantNotesController = TextEditingController(
      text: medical.importantNotes ?? '',
    );
    _doctorNameController = TextEditingController(text: medical.doctorName ?? '');
    _doctorPhoneController =
        TextEditingController(text: medical.doctorPhone ?? '');
    _allergiesController = TextEditingController(
      text: medical.allergies.join(', '),
    );
    _conditionsController = TextEditingController(
      text: medical.conditions.join(', '),
    );
    _medicationsController = TextEditingController(
      text: medical.medications.join(', '),
    );
    _dateOfBirth = widget.profile.dateOfBirth;
    _gender = widget.profile.gender;
    _contacts = [...widget.profile.pickupContacts];
    _bloodType = _bloodTypes.contains(medical.bloodType)
        ? medical.bloodType
        : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _importantNotesController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              _PhotoCard(
                profile: widget.profile,
                selectedPhoto: _selectedPhoto,
                onCameraTap: () => _pickPhoto(fromCamera: true),
                onGalleryTap: () => _pickPhoto(fromCamera: false),
              ),
              const SizedBox(height: 18),
              LBCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información básica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Ingresa el nombre'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Ingresa los apellidos'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickBirthDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          prefixIcon: Icon(LucideIcons.calendarDays),
                        ),
                        child: Text(_formatDate(_dateOfBirth)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'male',
                          icon: Icon(LucideIcons.shield),
                          label: Text('Niño'),
                        ),
                        ButtonSegment(
                          value: 'female',
                          icon: Icon(LucideIcons.sparkles),
                          label: Text('Niña'),
                        ),
                      ],
                      selected: {_gender},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _gender = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LBCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notas importantes e información médica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _importantNotesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Notas importantes',
                        hintText:
                            'Alergias críticas, recomendaciones o información que el colegio debe tener siempre visible.',
                        prefixIcon: Icon(LucideIcons.stickyNote),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _bloodType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de sangre',
                        prefixIcon: Icon(LucideIcons.droplets),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Sin especificar'),
                        ),
                        ..._bloodTypes.map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _bloodType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _doctorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor',
                        prefixIcon: Icon(LucideIcons.stethoscope),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _doctorPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono del doctor',
                        prefixIcon: Icon(LucideIcons.phone),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Alergias',
                        hintText: 'Ej. Lactosa, penicilina',
                        prefixIcon: Icon(LucideIcons.badgeAlert),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _conditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Condiciones médicas',
                        hintText: 'Ej. Asma, dermatitis',
                        prefixIcon: Icon(LucideIcons.shieldAlert),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _medicationsController,
                      decoration: const InputDecoration(
                        labelText: 'Medicamentos',
                        hintText: 'Ej. Inhalador, jarabe',
                        prefixIcon: Icon(LucideIcons.pill),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LBCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Personas autorizadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _addContact,
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Agrega foto de la persona y foto de su identificación para que el colegio pueda validar fácilmente la recogida.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_contacts.isEmpty)
                      const Text(
                        'Aún no hay personas autorizadas.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      )
                    else
                      ..._contacts.asMap().entries.map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == _contacts.length - 1 ? 0 : 12,
                          ),
                          child: _EditableContactTile(
                            contact: entry.value,
                            onEdit: () => _editContact(entry.key),
                            onDelete: () => _removeContact(entry.key),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final file = fromCamera
        ? await _imageService.capturePhoto()
        : await _imageService.pickFromGallery();

    if (file == null) return;

    if (!_imageService.validateFileSize(file)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La imagen excede el límite de 10 MB.')),
      );
      return;
    }

    setState(() {
      _selectedPhoto = file;
    });
  }

  Future<void> _addContact() async {
    final contact = await _showContactSheet();
    if (contact == null) return;

    setState(() {
      _contacts = [..._contacts, contact.copyWith(priority: _contacts.length + 1)];
    });
  }

  Future<void> _editContact(int index) async {
    final updated = await _showContactSheet(existing: _contacts[index]);
    if (updated == null) return;

    setState(() {
      _contacts = [..._contacts]..[index] = updated.copyWith(priority: index + 1);
    });
  }

  Future<void> _removeContact(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: const Text(
          'Esta persona dejará de estar autorizada para recoger al niño.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      final updated = [..._contacts]..removeAt(index);
      _contacts = updated
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(priority: entry.key + 1))
          .toList();
    });
  }

  Future<ChildPickupContact?> _showContactSheet({
    ChildPickupContact? existing,
  }) async {
    return showModalBottomSheet<ChildPickupContact>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (context) => ContactEditorSheet(
        existing: existing,
        imageService: _imageService,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final repository = ref.read(childProfileRepositoryProvider);

    try {
      String? uploadedPhotoReference;
      if (_selectedPhoto != null) {
        final uploaded = await _fileUploadService.uploadFile(
          file: _selectedPhoto!,
          purpose: 'child_profile_photo',
        );
        uploadedPhotoReference = uploaded.fileId;
      }

      await repository.updateProfile(
        widget.profile.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        photoUrl: uploadedPhotoReference,
      );

      final medicalInfo = ChildProfileMedicalInfo(
        allergies: _parseTags(_allergiesController.text),
        conditions: _parseTags(_conditionsController.text),
        medications: _parseTags(_medicationsController.text),
        bloodType: _bloodType,
        importantNotes: _importantNotesController.text.trim(),
        doctorName: _doctorNameController.text.trim(),
        doctorPhone: _doctorPhoneController.text.trim(),
      );
      await repository.upsertMedicalInfo(widget.profile.id, medicalInfo);

      await _syncContacts(repository);

      ref.invalidate(childProfileProvider(widget.profile.id));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _syncContacts(ChildProfileRepository repository) async {
    final preparedContacts = <ChildPickupContact>[];
    for (final contact in _contacts) {
      preparedContacts.add(await _uploadContactAssets(contact));
    }

    final originalById = {
      for (final contact in widget.profile.pickupContacts)
        if (contact.id != null) contact.id!: contact,
    };
    final currentIds = preparedContacts
        .where((contact) => contact.id != null)
        .map((contact) => contact.id!)
        .toSet();

    for (final originalId in originalById.keys) {
      if (!currentIds.contains(originalId)) {
        await repository.deletePickupContact(widget.profile.id, originalId);
      }
    }

    for (var index = 0; index < preparedContacts.length; index++) {
      final contact = preparedContacts[index].copyWith(priority: index + 1);
      final original = contact.id != null ? originalById[contact.id!] : null;

      if (contact.id == null) {
        await repository.addPickupContact(widget.profile.id, contact);
        continue;
      }

      if (original == null || !_contactsEqual(original, contact)) {
        await repository.updatePickupContact(widget.profile.id, contact);
      }
    }
  }

  Future<ChildPickupContact> _uploadContactAssets(
    ChildPickupContact contact,
  ) async {
    var updated = contact;

    if (contact.localPhotoFile != null) {
      final uploaded = await _fileUploadService.uploadFile(
        file: contact.localPhotoFile!,
        purpose: 'authorized_pickup_photo',
      );
      updated = updated.copyWith(photoUrl: uploaded.fileId);
    }

    if (contact.localIdPhotoFile != null) {
      final uploaded = await _fileUploadService.uploadFile(
        file: contact.localIdPhotoFile!,
        purpose: 'authorized_pickup_id',
      );
      updated = updated.copyWith(idPhotoUrl: uploaded.fileId);
    }

    return updated;
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.profile,
    required this.selectedPhoto,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final ChildProfileModel profile;
  final File? selectedPhoto;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final previewImage = selectedPhoto != null
        ? FileImage(selectedPhoto!)
        : profile.photoUrl != null
            ? NetworkImage(profile.photoUrl!)
            : null;

    return LBCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: previewImage as ImageProvider<Object>?,
            child: previewImage == null
                ? Text(
                    profile.firstName.isNotEmpty ? profile.firstName[0] : 'N',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          const Text(
            'Foto de perfil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'La nueva foto se guardará en la nube y se reflejará en todo el sistema.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: onGalleryTap,
                icon: const Icon(LucideIcons.image),
                label: const Text('Galería'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCameraTap,
                icon: const Icon(LucideIcons.camera),
                label: const Text('Cámara'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableContactTile extends StatelessWidget {
  const _EditableContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  final ChildPickupContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final previewImage = contact.localPhotoFile != null
        ? FileImage(contact.localPhotoFile!)
        : contact.photoUrl != null
            ? NetworkImage(contact.photoUrl!)
            : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: previewImage as ImageProvider<Object>?,
            child: previewImage == null
                ? Text(
                    contact.name.isNotEmpty ? contact.name[0] : 'R',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${contact.relationship} • ${contact.phone}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (contact.photoUrl != null || contact.localPhotoFile != null)
                      const _AssetBadge(label: 'Foto'),
                    if (contact.idPhotoUrl != null ||
                        contact.localIdPhotoFile != null)
                      const _AssetBadge(label: 'ID'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _AssetBadge extends StatelessWidget {
  const _AssetBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class ContactEditorSheet extends StatefulWidget {
  const ContactEditorSheet({
    super.key,
    this.existing,
    required this.imageService,
  });

  final ChildPickupContact? existing;
  final ImageService imageService;

  @override
  State<ContactEditorSheet> createState() => _ContactEditorSheetState();
}

class _ContactEditorSheetState extends State<ContactEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  File? _localPhotoFile;
  File? _localIdPhotoFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _relationshipController = TextEditingController(
      text: widget.existing?.relationship ?? '',
    );
    _phoneController = TextEditingController(text: widget.existing?.phone ?? '');
    _emailController = TextEditingController(text: widget.existing?.email ?? '');
    _localPhotoFile = widget.existing?.localPhotoFile;
    _localIdPhotoFile = widget.existing?.localIdPhotoFile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null
                        ? 'Agregar persona autorizada'
                        : 'Editar persona autorizada',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ContactAssetPicker(
              title: 'Foto de la persona',
              subtitle: 'Ayuda a reconocer rápidamente quién recoge al niño.',
              remoteUrl: widget.existing?.photoUrl,
              localFile: _localPhotoFile,
              onCameraTap: () => _pickAsset(
                fromCamera: true,
                isId: false,
              ),
              onGalleryTap: () => _pickAsset(
                fromCamera: false,
                isId: false,
              ),
            ),
            const SizedBox(height: 16),
            _ContactAssetPicker(
              title: 'Foto de identificación',
              subtitle: 'Sube una credencial o identificación por seguridad.',
              remoteUrl: widget.existing?.idPhotoUrl,
              localFile: _localIdPhotoFile,
              onCameraTap: () => _pickAsset(
                fromCamera: true,
                isId: true,
              ),
              onGalleryTap: () => _pickAsset(
                fromCamera: false,
                isId: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Ingresa el nombre'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(labelText: 'Relación'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Ingresa la relación'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Ingresa el teléfono'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (opcional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: const Text('Guardar persona'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAsset({
    required bool fromCamera,
    required bool isId,
  }) async {
    final file = fromCamera
        ? await widget.imageService.capturePhoto()
        : await widget.imageService.pickFromGallery();

    if (file == null) return;

    if (!widget.imageService.validateFileSize(file)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La imagen excede el límite de 10 MB.')),
      );
      return;
    }

    setState(() {
      if (isId) {
        _localIdPhotoFile = file;
      } else {
        _localPhotoFile = file;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      ChildPickupContact(
        id: widget.existing?.id,
        name: _nameController.text.trim(),
        relationship: _relationshipController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        photoUrl: widget.existing?.photoUrl,
        idPhotoUrl: widget.existing?.idPhotoUrl,
        localPhotoFile: _localPhotoFile,
        localIdPhotoFile: _localIdPhotoFile,
        priority: widget.existing?.priority ?? 1,
      ),
    );
  }
}

class _ContactAssetPicker extends StatelessWidget {
  const _ContactAssetPicker({
    required this.title,
    required this.subtitle,
    required this.remoteUrl,
    required this.localFile,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final String title;
  final String subtitle;
  final String? remoteUrl;
  final File? localFile;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final previewImage = localFile != null
        ? FileImage(localFile!)
        : remoteUrl != null
            ? NetworkImage(remoteUrl!)
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: previewImage as ImageProvider<Object>?,
                child: previewImage == null
                    ? const Icon(LucideIcons.image, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
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
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: onGalleryTap,
                icon: const Icon(LucideIcons.image, size: 16),
                label: const Text('Galería'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCameraTap,
                icon: const Icon(LucideIcons.camera, size: 16),
                label: const Text('Cámara'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<String> _parseTags(String rawValue) {
  return rawValue
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

bool _contactsEqual(ChildPickupContact a, ChildPickupContact b) {
  return a.name == b.name &&
      a.relationship == b.relationship &&
      a.phone == b.phone &&
      a.email == b.email &&
      a.photoUrl == b.photoUrl &&
      a.idPhotoUrl == b.idPhotoUrl &&
      a.priority == b.priority;
}
