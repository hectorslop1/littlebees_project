import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../../../shared/enums/enums.dart';
import '../../auth/application/auth_provider.dart';
import '../application/ai_assistant_provider.dart';
import '../domain/ai_chat_models.dart';
import 'widgets/beea_avatar.dart';

class AiAssistantFab extends StatelessWidget {
  const AiAssistantFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: FloatingActionButton(
        heroTag: 'ai-assistant-fab',
        onPressed: () => context.pushNamed(RouteNames.aiAssistant),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        child: const BeeaAvatar(
          size: 60,
          outerColor: Colors.transparent,
          padding: EdgeInsets.zero,
          showShadow: true,
        ),
      ),
    );
  }
}

Future<void> showAiAssistantSheet(BuildContext context) async {
  await context.pushNamed(RouteNames.aiAssistant);
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchMode = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(aiAssistantProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  List<AiChatMessage> _filterMessages(List<AiChatMessage> messages) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return messages;

    return messages.where((message) {
      return message.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(aiAssistantProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    final state = ref.watch(aiAssistantProvider);
    final authState = ref.watch(authProvider);
    final welcome = ref.watch(aiAssistantWelcomeProvider);
    final promptHint = ref.watch(aiAssistantPromptHintProvider);
    final displayName = authState.user?.firstName ?? 'Usuario';
    final messages = _filterMessages(state.messages);
    final hasActiveSession = state.activeSessionId != null;

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (hasActiveSession) {
              ref.read(aiAssistantProvider.notifier).clearActiveSession();
              setState(() {
                _isSearchMode = false;
                _searchQuery = '';
                _searchController.clear();
              });
              return;
            }
            context.pop();
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: hasActiveSession && _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar en Beea...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Beea'),
        actions: [
          if (hasActiveSession)
            IconButton(
              onPressed: () {
                setState(() {
                  if (_isSearchMode) {
                    _isSearchMode = false;
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _isSearchMode = true;
                  }
                });
              },
              icon: Icon(_isSearchMode ? LucideIcons.x : LucideIcons.search),
            ),
          if (!hasActiveSession)
            IconButton(
              tooltip: 'Nueva conversación',
              onPressed: () async {
                await ref.read(aiAssistantProvider.notifier).startSession();
              },
              icon: const Icon(LucideIcons.plusCircle),
            ),
          if (hasActiveSession)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'new') {
                  await ref.read(aiAssistantProvider.notifier).startSession();
                  return;
                }

                if (value == 'delete' && state.activeSessionId != null) {
                  await ref
                      .read(aiAssistantProvider.notifier)
                      .deleteSession(state.activeSessionId!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new',
                  child: Text('Nueva conversación'),
                ),
                if (state.activeSessionId != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar conversación'),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !hasActiveSession
                ? _AiSessionsList(
                    sessions: state.sessions,
                    onNewConversation: () async {
                      await ref.read(aiAssistantProvider.notifier).startSession();
                    },
                    onOpenSession: (sessionId) async {
                      await ref
                          .read(aiAssistantProvider.notifier)
                          .selectSession(sessionId);
                    },
                    onDeleteSession: (sessionId) async {
                      await ref
                          .read(aiAssistantProvider.notifier)
                          .deleteSession(sessionId);
                    },
                  )
                : messages.isEmpty
                ? _AiEmptyState(
                    displayName: displayName,
                    welcome: welcome,
                    onSuggestionTap: (message) {
                      _controller.text = message;
                      _send();
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _AiMessageBubble(message: message);
                    },
                  ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: hasActiveSession
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.appColor(AppColors.surface),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: context.appColor(AppColors.border),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 5,
                            onSubmitted: (_) => _send(),
                            style: TextStyle(
                              color: context.appColor(AppColors.textPrimary),
                              fontSize: 16,
                              height: 1.35,
                            ),
                            decoration: InputDecoration(
                              hintText: promptHint,
                              hintStyle: TextStyle(
                                color: context.appColor(AppColors.textSecondary),
                                fontSize: 16,
                                height: 1.35,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FloatingActionButton.small(
                        heroTag: 'ai-assistant-send',
                        onPressed: state.isSending ? null : _send,
                        backgroundColor: AppColors.primary,
                        child: state.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Icon(
                                LucideIcons.send,
                                color: AppColors.textOnPrimary,
                              ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AiSessionsList extends StatelessWidget {
  const _AiSessionsList({
    required this.sessions,
    required this.onNewConversation,
    required this.onOpenSession,
    required this.onDeleteSession,
  });

  final List<AiChatSession> sessions;
  final Future<void> Function() onNewConversation;
  final Future<void> Function(String sessionId) onOpenSession;
  final Future<void> Function(String sessionId) onDeleteSession;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8EBC8), Color(0xFFE7F0FB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              const BeeaAvatar(size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Conversa con Beea',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Abre una conversación previa o empieza una nueva para recibir ayuda con contexto real.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onNewConversation,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.appColor(AppColors.surface),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: context.appColor(AppColors.border)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.plusCircle, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nueva conversación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronRight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Conversaciones anteriores',
          style: TextStyle(
            color: context.appColor(AppColors.textSecondary),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.appColor(AppColors.surface),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.appColor(AppColors.border)),
            ),
            child: Column(
              children: [
                const BeeaAvatar(size: 56),
                const SizedBox(height: 12),
                const Text(
                  'Todavía no tienes conversaciones con Beea',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu historial aparecerá aquí para que retomes cualquier consulta cuando lo necesites.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.appColor(AppColors.textSecondary),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
        else
          ...sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: context.appColor(AppColors.surface),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onOpenSession(session.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const BeeaAvatar(size: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'd MMM • h:mma',
                                ).format(session.updatedAt).toLowerCase(),
                                style: TextStyle(
                                  color: context.appColor(
                                    AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => onDeleteSession(session.id),
                          icon: const Icon(LucideIcons.trash2, size: 18),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : context.appColor(AppColors.surface),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser
                    ? AppColors.textOnPrimary
                    : context.appColor(AppColors.textPrimary),
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('h:mma').format(message.createdAt).toLowerCase(),
              style: TextStyle(
                color: isUser
                    ? Colors.white.withAlpha(210)
                    : context.appColor(AppColors.textSecondary),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiEmptyState extends ConsumerWidget {
  const _AiEmptyState({
    required this.onSuggestionTap,
    required this.displayName,
    required this.welcome,
  });

  final ValueChanged<String> onSuggestionTap;
  final String displayName;
  final String welcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role;
    final suggestions = switch (role) {
      UserRole.parent => const [
        '¿Cómo va hoy mi hijo y qué debería reforzar en casa?',
        'Explícame las actividades recientes de mi hijo.',
      ],
      UserRole.teacher => const [
        'Ayúdame a resumir la jornada del grupo.',
        'Sugiere actividades pedagógicas para hoy.',
      ],
      _ => const [
        'Dame un resumen operativo del día.',
        '¿Qué pendientes importantes tengo hoy?',
      ],
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8EBC8), Color(0xFFE7F0FB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: const BeeaAvatar(size: 56),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hola, soy Beea',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Estoy aquí para ayudarte con respuestas claras, útiles y basadas en información real de LittleBees. $displayName, $welcome',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            'Elige una sugerencia para empezar o pregúntame algo directamente.',
            style: TextStyle(
              color: context.appColor(AppColors.textSecondary),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
        ...suggestions.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSuggestionTap(item),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.surface),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: context.appColor(AppColors.border)),
                ),
                child: Row(
                  children: [
                    const BeeaAvatar(size: 40),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
