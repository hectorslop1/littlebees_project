import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_card.dart';
import '../../../shared/enums/enums.dart';
import '../../auth/application/auth_provider.dart';
import '../application/conversations_provider.dart';
import '../domain/chat_contact.dart';

class NewConversationScreen extends ConsumerWidget {
  const NewConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final contactsAsync = ref.watch(availableChatContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Conversación'), elevation: 0),
      body: SafeArea(
        child: contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No hay contactos disponibles para iniciar una conversación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            final groupedContacts = <String, List<ChatContact>>{
              'teachers': [],
              'administration': [],
              'parents': [],
            };

            for (final contact in contacts) {
              groupedContacts.putIfAbsent(contact.category, () => []);
              groupedContacts[contact.category]!.add(contact);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (groupedContacts['teachers']!.isNotEmpty) ...[
                  _buildSectionTitle(user?.role, 'teachers'),
                  ...groupedContacts['teachers']!.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildContactCard(context, ref, contact),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (groupedContacts['administration']!.isNotEmpty) ...[
                  _buildSectionTitle(user?.role, 'administration'),
                  ...groupedContacts['administration']!.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildContactCard(context, ref, contact),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (groupedContacts['parents']!.isNotEmpty) ...[
                  _buildSectionTitle(user?.role, 'parents'),
                  ...groupedContacts['parents']!.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildContactCard(context, ref, contact),
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No fue posible cargar los contactos.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(UserRole? userRole, String category) {
    String title;
    switch (category) {
      case 'teachers':
        title = userRole == UserRole.parent
            ? 'Maestras de mis hijos'
            : 'Personal docente';
        break;
      case 'administration':
        title = 'Dirección';
        break;
      case 'parents':
        title = userRole == UserRole.teacher ? 'Familias' : 'Padres';
        break;
      default:
        title = 'Contactos';
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    WidgetRef ref,
    ChatContact contact,
  ) {
    return LBCard(
      onTap: () => _handleContactTap(context, ref, contact),
      child: Row(
        children: [
          LBAvatar(
            placeholder: contact.displayName.isNotEmpty
                ? contact.displayName
                : _roleLabel(contact.role),
            imageUrl: contact.avatarUrl,
            size: LBAvatarSize.normal,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _buildSubtitle(contact),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Future<void> _handleContactTap(
    BuildContext context,
    WidgetRef ref,
    ChatContact contact,
  ) async {
    final selectedChildId = await _resolveChildForContact(context, contact);
    if (selectedChildId == null) {
      return;
    }

    try {
      final conversation = await ref
          .read(conversationsNotifierProvider.notifier)
          .createConversation(
            participantId: contact.userId,
            childId: selectedChildId,
          );

      if (!context.mounted) {
        return;
      }

      context.push(
        '/messages/${conversation.id}',
        extra: {
          'participantName': conversation.participantName,
          'participantAvatarUrl': conversation.participantAvatarUrl,
          'participantRole': conversation.participantRole,
        },
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible abrir la conversación: $error')),
      );
    }
  }

  Future<String?> _resolveChildForContact(
    BuildContext context,
    ChatContact contact,
  ) async {
    if (contact.childIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este contacto no tiene niños asociados.'),
        ),
      );
      return null;
    }

    if (contact.childIds.length == 1) {
      return contact.childIds.first;
    }

    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Selecciona al niño relacionado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            for (var index = 0; index < contact.childIds.length; index++)
              ListTile(
                leading: const Icon(LucideIcons.baby),
                title: Text(contact.childNames[index]),
                subtitle: index < contact.groupNames.length
                    ? Text(contact.groupNames[index])
                    : null,
                onTap: () => Navigator.of(context).pop(contact.childIds[index]),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(ChatContact contact) {
    final relatedChildren = contact.childNames.join(', ');
    final roleLabel = _roleLabel(contact.role);

    if (relatedChildren.isEmpty) {
      return roleLabel;
    }

    return '$roleLabel • $relatedChildren';
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'teacher':
        return 'Maestra';
      case 'director':
        return 'Dirección';
      case 'admin':
      case 'super_admin':
        return 'Administración';
      case 'parent':
        return 'Familia';
      default:
        return 'Contacto';
    }
  }
}
