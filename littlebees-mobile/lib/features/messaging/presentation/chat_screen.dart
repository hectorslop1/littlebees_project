import 'dart:async';
import 'dart:io';

import 'package:circular_menu/circular_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../core/i18n/app_translations.dart';
import '../../../core/services/file_upload_service.dart';
import '../../../core/services/image_service.dart';
import '../../../core/utils/resolve_image_url.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/widgets/full_screen_image_viewer.dart';
import '../../../design_system/widgets/lb_avatar.dart';
import '../../../design_system/widgets/lb_empty_state.dart';
import '../../../design_system/widgets/lb_error_state.dart';
import '../../../shared/models/message_model.dart';
import '../../auth/application/auth_provider.dart';
import '../application/conversations_provider.dart';
import '../application/realtime_messaging_provider.dart';
import '../domain/call_log.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
    this.participantRole,
  });

  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;
  final String? participantRole;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<CircularMenuState> _attachmentMenuKey =
      GlobalKey<CircularMenuState>();
  final ImageService _imageService = ImageService();
  final FileUploadService _fileUploadService = FileUploadService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _showCallHistory = false;
  bool _isSearchMode = false;
  bool _isTyping = false;
  bool _isUploadingAttachment = false;
  bool _isRecordingVoiceNote = false;
  bool _isAttachmentMenuOpen = false;
  String? _voiceRecordingPath;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    Future.microtask(() {
      ref.read(activeConversationIdProvider.notifier).state =
          widget.conversationId;
      ref
          .read(conversationsNotifierProvider.notifier)
          .markAsRead(widget.conversationId);
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      ref
          .read(realtimeMessagingProvider(widget.conversationId).notifier)
          .startTyping();
    } else if (text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
      ref
          .read(realtimeMessagingProvider(widget.conversationId).notifier)
          .stopTyping();
    }
  }

  Future<void> _sendTextMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final content = _controller.text.trim();
    _controller.clear();
    setState(() => _isTyping = false);

    await _sendSocketMessage(content: content);
  }

  Future<void> _sendSocketMessage({
    required String content,
    String? attachmentUrl,
    String? messageType,
  }) async {
    try {
      await ref
          .read(realtimeMessagingProvider(widget.conversationId).notifier)
          .sendMessage(
            content,
            attachmentUrl: attachmentUrl,
            messageType: messageType,
          );

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible enviar el mensaje: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openAttachmentSheet() async {
    if (_isUploadingAttachment || _isRecordingVoiceNote) return;

    final menuState = _attachmentMenuKey.currentState;
    if (menuState == null) return;

    if (_isAttachmentMenuOpen) {
      menuState.reverseAnimation();
    } else {
      menuState.forwardAnimation();
    }

    setState(() {
      _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
    });
  }

  Future<void> _selectAttachmentOption(_AttachmentOption option) async {
    if (_isAttachmentMenuOpen) {
      _attachmentMenuKey.currentState?.reverseAnimation();
      if (mounted) {
        setState(() {
          _isAttachmentMenuOpen = false;
        });
      }
    }

    switch (option) {
      case _AttachmentOption.camera:
        await _sendImageFromCamera();
        break;
      case _AttachmentOption.gallery:
        await _sendImageFromGallery();
        break;
      case _AttachmentOption.videoCamera:
        await _sendVideoFromCamera();
        break;
      case _AttachmentOption.videoGallery:
        await _sendVideoFromGallery();
        break;
      case _AttachmentOption.file:
        await _sendFileAttachment();
        break;
      case _AttachmentOption.audio:
        await _handleVoiceNoteTap();
        break;
    }
  }

  Future<void> _sendImageFromCamera() async {
    final file = await _imageService.capturePhoto();
    if (file == null) return;
    await _uploadAndSendAttachment(
      file: file,
      messageType: 'image',
      fallbackContent: 'Imagen',
    );
  }

  Future<void> _sendImageFromGallery() async {
    final file = await _imageService.pickFromGallery();
    if (file == null) return;
    await _uploadAndSendAttachment(
      file: file,
      messageType: 'image',
      fallbackContent: 'Imagen',
    );
  }

  Future<void> _sendFileAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;

    await _uploadAndSendAttachment(
      file: File(path),
      messageType: 'file',
      fallbackContent: result?.files.single.name ?? 'Archivo adjunto',
      preferFilename: true,
    );
  }

  Future<void> _sendVideoFromCamera() async {
    final file = await _imageService.captureVideo();
    if (file == null) return;
    await _compressUploadAndSendVideo(file);
  }

  Future<void> _sendVideoFromGallery() async {
    final file = await _imageService.pickVideoFromGallery();
    if (file == null) return;
    await _compressUploadAndSendVideo(file);
  }

  Future<void> _compressUploadAndSendVideo(File originalFile) async {
    try {
      setState(() {
        _isUploadingAttachment = true;
      });

      final compressedInfo = await VideoCompress.compressVideo(
        originalFile.path,
        quality: VideoQuality.MediumQuality,
        includeAudio: true,
        deleteOrigin: false,
      );

      final compressedPath = compressedInfo?.file?.path ?? originalFile.path;
      final compressedFile = File(compressedPath);

      await _uploadAndSendAttachment(
        file: compressedFile,
        messageType: 'video',
        fallbackContent: 'Video',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible comprimir el video: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      await VideoCompress.cancelCompression();
      await VideoCompress.deleteAllCache();
      if (mounted) {
        setState(() {
          _isUploadingAttachment = false;
        });
      }
    }
  }

  Future<void> _uploadAndSendAttachment({
    required File file,
    required String messageType,
    required String fallbackContent,
    bool preferFilename = false,
  }) async {
    try {
      setState(() {
        _isUploadingAttachment = true;
      });

      final uploaded = await _fileUploadService.uploadFile(
        file: file,
        purpose: 'chat_attachment',
      );

      await _sendSocketMessage(
        content: preferFilename && uploaded.filename.isNotEmpty
            ? uploaded.filename
            : fallbackContent,
        attachmentUrl: uploaded.fileId,
        messageType: messageType,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible subir el adjunto: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAttachment = false;
        });
      }
    }
  }

  Future<void> _handleVoiceNoteTap() async {
    if (_isRecordingVoiceNote) {
      await _finishVoiceRecording(send: true);
      return;
    }

    try {
      if (!await _audioRecorder.hasPermission()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hace falta permiso de micrófono para grabar audio'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      if (!mounted) return;
      setState(() {
        _isRecordingVoiceNote = true;
        _voiceRecordingPath = filePath;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible iniciar la grabación: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _finishVoiceRecording({required bool send}) async {
    try {
      final path = await _audioRecorder.stop();
      final recordedPath = path ?? _voiceRecordingPath;

      if (mounted) {
        setState(() {
          _isRecordingVoiceNote = false;
          _voiceRecordingPath = null;
        });
      }

      if (!send || recordedPath == null) {
        if (recordedPath != null) {
          final file = File(recordedPath);
          if (await file.exists()) {
            await file.delete();
          }
        }
        return;
      }

      await _uploadAndSendAttachment(
        file: File(recordedPath),
        messageType: 'audio',
        fallbackContent: 'Nota de voz',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible guardar la nota de voz: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _makeVoiceCall() {
    context.push(
      '/messages/${widget.conversationId}/call',
      extra: {
        'participantName': widget.participantName,
        'participantAvatarUrl': widget.participantAvatarUrl,
        'participantRole': widget.participantRole,
        'callType': 'voice',
        'isOutgoing': true,
      },
    );
  }

  void _makeVideoCall() {
    context.push(
      '/messages/${widget.conversationId}/call',
      extra: {
        'participantName': widget.participantName,
        'participantAvatarUrl': widget.participantAvatarUrl,
        'participantRole': widget.participantRole,
        'callType': 'video',
        'isOutgoing': true,
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'pm' : 'am';
      return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')}$period';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} dias';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  List<Message> _filterMessages(List<Message> messages) {
    if (_searchQuery.trim().isEmpty) {
      return messages;
    }

    final query = _searchQuery.trim().toLowerCase();
    return messages.where((message) {
      final searchable = [
        message.content,
        message.senderName,
        message.attachmentType ?? '',
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    final activeConversationId = ref.read(activeConversationIdProvider);
    if (activeConversationId == widget.conversationId) {
      ref.read(activeConversationIdProvider.notifier).state = null;
    }
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      realtimeMessagingProvider(widget.conversationId),
    );
    final connectionAsync = ref.watch(socketConnectionProvider);
    final currentUser = ref.watch(currentUserProvider);
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 28),
          onPressed: () {
            if (_isSearchMode) {
              setState(() {
                _isSearchMode = false;
                _searchQuery = '';
                _searchController.clear();
              });
              return;
            }
            context.pop();
          },
        ),
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar mensajes...',
                  border: InputBorder.none,
                ),
              )
            : Row(
                children: [
                  LBAvatar(
                    placeholder: widget.participantName.isNotEmpty
                        ? widget.participantName.substring(0, 1)
                        : 'U',
                    imageUrl: widget.participantAvatarUrl,
                    size: LBAvatarSize.small,
                    showStatusDot: true,
                    statusColor: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.participantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        connectionAsync.when(
                          data: (isConnected) => Text(
                            isConnected ? 'En linea' : 'Sin conexion',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isConnected
                                      ? AppColors.success
                                      : AppColors.textTertiary,
                                ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          if (!_showCallHistory)
            IconButton(
              icon: Icon(
                _isSearchMode ? LucideIcons.x : LucideIcons.search,
                size: 20,
              ),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              onPressed: () {
                setState(() {
                  _isSearchMode = !_isSearchMode;
                  if (!_isSearchMode) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
              tooltip: 'Buscar',
            ),
          IconButton(
                icon: const Icon(LucideIcons.phone, size: 22),
                onPressed: _makeVoiceCall,
                tooltip: 'Llamar',
                visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          IconButton(
                icon: const Icon(LucideIcons.video, size: 22),
                onPressed: _makeVideoCall,
                tooltip: 'Videollamada',
                visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, size: 22),
            onSelected: (value) {
              if (value == 'call_history') {
                setState(() {
                  _showCallHistory = !_showCallHistory;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'call_history',
                child: Row(
                  children: [
                    Icon(
                      _showCallHistory
                          ? LucideIcons.messageSquare
                          : LucideIcons.phoneCall,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _showCallHistory
                          ? 'Ver mensajes'
                          : 'Historial de llamadas',
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
        ],
      ),
      body: _showCallHistory
          ? Column(
        children: [
          Expanded(
            child: _showCallHistory
                ? messagesAsync.when(
                    data: (messages) =>
                        _buildCallHistory(messages, currentUser?.id),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => LBErrorState(
                      title: tr.tr('errorLoadingData'),
                      message: error.toString(),
                      onRetry: () => ref.refresh(
                        realtimeMessagingProvider(widget.conversationId),
                      ),
                    ),
                  )
                : messagesAsync.when(
                    data: (messages) {
                      final visibleMessages = _filterMessages(messages);
                      return visibleMessages.isEmpty
                          ? LBEmptyState(
                              icon: LucideIcons.messageSquare,
                              title: _searchQuery.isEmpty
                                  ? tr.tr('noMessages')
                                  : 'Sin resultados',
                              message: _searchQuery.isEmpty
                                  ? tr.tr('noMessagesMsg')
                                  : 'No encontramos mensajes con ese texto.',
                            )
                          : _buildMessagesList(
                              visibleMessages,
                              currentUser?.id,
                            );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => LBErrorState(
                      title: tr.tr('errorLoadingData'),
                      message: error.toString(),
                      onRetry: () => ref.refresh(
                        realtimeMessagingProvider(widget.conversationId),
                      ),
                    ),
                  ),
          ),
          if (!_showCallHistory) _buildInputBar(),
        ],
      )
          : CircularMenu(
              key: _attachmentMenuKey,
              alignment: Alignment.bottomLeft,
              radius: 132,
              animationDuration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              toggleButtonColor: Colors.transparent,
              toggleButtonAnimatedIconData: AnimatedIcons.close_menu,
              toggleButtonBoxShadow: const [],
              toggleButtonSize: 8,
              toggleButtonMargin: 28,
              toggleButtonPadding: 0,
              toggleButtonIconColor: Colors.transparent,
              startingAngleInRadian: 4.82,
              endingAngleInRadian: 6.18,
              backgroundWidget: Column(
                children: [
                  Expanded(
                    child: messagesAsync.when(
                      data: (messages) {
                        final visibleMessages = _filterMessages(messages);
                        return visibleMessages.isEmpty
                            ? LBEmptyState(
                                icon: LucideIcons.messageSquare,
                                title: _searchQuery.isEmpty
                                    ? tr.tr('noMessages')
                                    : 'Sin resultados',
                                message: _searchQuery.isEmpty
                                    ? tr.tr('noMessagesMsg')
                                    : 'No encontramos mensajes con ese texto.',
                              )
                            : _buildMessagesList(
                                visibleMessages,
                                currentUser?.id,
                              );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => LBErrorState(
                        title: tr.tr('errorLoadingData'),
                        message: error.toString(),
                        onRetry: () => ref.refresh(
                          realtimeMessagingProvider(widget.conversationId),
                        ),
                      ),
                    ),
                  ),
                  _buildInputBar(),
                ],
              ),
              items: [
                CircularMenuItem(
                  icon: LucideIcons.camera,
                  color: AppColors.primary,
                  iconSize: 20,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  onTap: () => _selectAttachmentOption(_AttachmentOption.camera),
                ),
                CircularMenuItem(
                  icon: LucideIcons.image,
                  color: AppColors.info,
                  iconSize: 20,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  onTap: () =>
                      _selectAttachmentOption(_AttachmentOption.gallery),
                ),
                CircularMenuItem(
                  icon: LucideIcons.film,
                  color: const Color(0xFF8A74F8),
                  iconSize: 20,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  onTap: () =>
                      _selectAttachmentOption(_AttachmentOption.videoGallery),
                ),
                CircularMenuItem(
                  icon: LucideIcons.file,
                  color: AppColors.secondary,
                  iconSize: 20,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  onTap: () => _selectAttachmentOption(_AttachmentOption.file),
                ),
              ],
            ),
    );
  }

  Widget _buildMessagesList(List<Message> messages, String? currentUserId) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[messages.length - 1 - index];
        final isMe = msg.senderId == currentUserId;
        final callLog = parseCallLog(msg);

        if (callLog != null && currentUserId != null) {
          return _buildCallLogBubble(msg, callLog, currentUserId, isMe);
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child:
              _ChatBubble(
                    isMe: isMe,
                    timestamp: _formatTime(msg.createdAt),
                    isRead: msg.isRead,
                    child: _buildMessageBody(msg, isMe),
                  )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .slideX(begin: isMe ? 0.1 : -0.1, end: 0),
        );
      },
    );
  }

  Widget _buildMessageBody(Message msg, bool isMe) {
    switch (msg.attachmentType) {
      case 'image':
        return _ImageAttachmentMessage(
          imageUrl: msg.attachmentUrl,
          caption: _normalizeAttachmentCaption(msg.content, 'Imagen'),
          isMe: isMe,
        );
      case 'file':
        return _FileAttachmentMessage(
          title:
              _normalizeAttachmentCaption(msg.content, 'Archivo adjunto') ??
              'Archivo adjunto',
          attachmentUrl: msg.attachmentUrl,
          isMe: isMe,
        );
      case 'audio':
        return _AudioAttachmentMessage(
          attachmentUrl: msg.attachmentUrl,
          label:
              _normalizeAttachmentCaption(msg.content, 'Nota de voz') ??
              'Nota de voz',
          isMe: isMe,
        );
      case 'video':
        return _VideoAttachmentMessage(
          attachmentUrl: msg.attachmentUrl,
          caption: _normalizeAttachmentCaption(msg.content, 'Video'),
          isMe: isMe,
        );
      default:
        return Text(
          msg.content,
          style: TextStyle(
            color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        );
    }
  }

  String? _normalizeAttachmentCaption(String content, String defaultValue) {
    if (content.trim().isEmpty) return null;
    if (content == defaultValue) return null;
    if (_looksLikeGeneratedAttachmentName(content)) return null;
    return content;
  }

  bool _looksLikeGeneratedAttachmentName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.contains('image_picker_') ||
        normalized.contains('voice_note_') ||
        normalized.contains('ph_asset_') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.png') ||
        normalized.endsWith('.heic') ||
        normalized.endsWith('.m4a') ||
        normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov');
  }

  Widget _buildCallLogBubble(
    Message message,
    ParsedCallLog callLog,
    String currentUserId,
    bool isMe,
  ) {
    final title = buildCallTitle(callLog, currentUserId);
    final subtitle = buildCallSubtitle(callLog);
    final isVideo = callLog.isVideo;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primarySurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isMe ? AppColors.primaryLight : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (isVideo ? AppColors.info : AppColors.primary)
                            .withAlpha(24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isVideo ? LucideIcons.video : LucideIcons.phoneCall,
                        color: isVideo ? AppColors.info : AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(message.createdAt),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 250.ms)
              .slideX(begin: isMe ? 0.1 : -0.1, end: 0),
    );
  }

  Widget _buildCallHistory(List<Message> messages, String? currentUserId) {
    final callMessages = messages
        .where((message) => message.attachmentType == 'call_log')
        .toList()
        .reversed
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.phoneCall,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Historial de llamadas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
        Expanded(
          child: callMessages.isEmpty
              ? const Center(
                  child: Text(
                    'Aun no hay llamadas registradas.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: callMessages.length,
                  itemBuilder: (context, index) {
                    final message = callMessages[index];
                    final callLog = parseCallLog(message);
                    if (callLog == null || currentUserId == null) {
                      return const SizedBox.shrink();
                    }

                    final isIncoming = callLog.callerId != currentUserId;
                    final wasAnswered = callLog.status == 'completed';
                    final isVideo = callLog.isVideo;

                    return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: wasAnswered
                                      ? AppColors.primarySurface
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isVideo
                                      ? LucideIcons.video
                                      : LucideIcons.phone,
                                  size: 20,
                                  color: wasAnswered
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isIncoming
                                              ? LucideIcons.phoneIncoming
                                              : LucideIcons.phoneOutgoing,
                                          size: 14,
                                          color: wasAnswered
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isIncoming ? 'Entrante' : 'Saliente',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        if (!wasAnswered) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${buildCallSubtitle(callLog)})',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.error,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'dd MMM, hh:mm a',
                                      ).format(message.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (callLog.durationSeconds > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formatCallDuration(callLog.durationSeconds),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                        .slideX(begin: -0.1, end: 0);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    final hasText = _controller.text.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecordingVoiceNote)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.mic,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Grabando nota de voz...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _finishVoiceRecording(send: false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () => _finishVoiceRecording(send: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                onPressed: _isUploadingAttachment ? null : _openAttachmentSheet,
                icon: Icon(
                  _isAttachmentMenuOpen ? LucideIcons.x : LucideIcons.paperclip,
                  color: _isUploadingAttachment
                      ? AppColors.textTertiary
                      : (_isAttachmentMenuOpen
                            ? AppColors.primary
                            : AppColors.textSecondary),
                ),
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isRecordingVoiceNote,
                  decoration: InputDecoration(
                    hintText: _isRecordingVoiceNote
                        ? 'La nota de voz se enviará al detener la grabación'
                        : 'Escribe un mensaje...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
              const SizedBox(width: 8),
              if (_isUploadingAttachment)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                      onPressed: _isRecordingVoiceNote
                          ? null
                          : (hasText ? _sendTextMessage : _handleVoiceNoteTap),
                      icon: Icon(
                        hasText
                            ? LucideIcons.send
                            : (_isRecordingVoiceNote
                                  ? LucideIcons.square
                                  : LucideIcons.mic),
                        color: _isRecordingVoiceNote
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                      target: hasText ? 1 : 0,
                    )
                    .scale(end: const Offset(1.1, 1.1), duration: 600.ms),
            ],
          ),
        ],
      ),
    );
  }
}

enum _AttachmentOption {
  camera,
  gallery,
  videoCamera,
  videoGallery,
  file,
  audio,
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isMe,
    required this.timestamp,
    required this.isRead,
    required this.child,
  });

  final bool isMe;
  final String timestamp;
  final bool isRead;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomRight: isMe
              ? const Radius.circular(4)
              : const Radius.circular(16),
          bottomLeft: !isMe
              ? const Radius.circular(4)
              : const Radius.circular(16),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(alignment: Alignment.centerLeft, child: child),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timestamp,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? AppColors.textOnPrimary.withAlpha(180)
                      : AppColors.textTertiary,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 14,
                  color: isRead
                      ? AppColors.success.withAlpha(200)
                      : AppColors.textOnPrimary.withAlpha(200),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageAttachmentMessage extends StatelessWidget {
  const _ImageAttachmentMessage({
    required this.imageUrl,
    required this.caption,
    required this.isMe,
  });

  final String? imageUrl;
  final String? caption;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(imageUrl);
    if (resolvedUrl == null) {
      return Text(
        caption ?? 'Imagen no disponible',
        style: TextStyle(
          color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FullScreenImageViewer(imageUrl: resolvedUrl),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              resolvedUrl,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 220,
                height: 220,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.imageOff,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            caption!,
            style: TextStyle(
              color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _FileAttachmentMessage extends StatelessWidget {
  const _FileAttachmentMessage({
    required this.title,
    required this.attachmentUrl,
    required this.isMe,
  });

  final String title;
  final String? attachmentUrl;
  final bool isMe;

  Future<void> _openFile() async {
    final resolvedUrl = resolveImageUrl(attachmentUrl);
    if (resolvedUrl == null) return;

    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: attachmentUrl == null ? null : _openFile,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withAlpha(18) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.fileText,
              color: isMe ? AppColors.textOnPrimary : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isMe
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    attachmentUrl == null
                        ? 'Archivo no disponible'
                        : 'Toca para abrir',
                    style: TextStyle(
                      color: isMe
                          ? AppColors.textOnPrimary.withAlpha(180)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioAttachmentMessage extends StatefulWidget {
  const _AudioAttachmentMessage({
    required this.attachmentUrl,
    required this.label,
    required this.isMe,
  });

  final String? attachmentUrl;
  final String label;
  final bool isMe;

  @override
  State<_AudioAttachmentMessage> createState() =>
      _AudioAttachmentMessageState();
}

class _AudioAttachmentMessageState extends State<_AudioAttachmentMessage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
    _audioPlayer.durationStream.listen((duration) {
      if (!mounted || duration == null) return;
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _togglePlayback() async {
    final resolvedUrl = resolveImageUrl(widget.attachmentUrl);
    if (resolvedUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nota de voz todavía no está disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      if (_loadedUrl != resolvedUrl) {
        await _audioPlayer.setUrl(resolvedUrl);
        _loadedUrl = resolvedUrl;
      }

      if (_position >= _duration && _duration > Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible reproducir la nota de voz'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0, 1);
    final foreground = widget.isMe
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isMe
            ? Colors.white.withAlpha(18)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _togglePlayback,
            icon: Icon(
              _isPlaying ? LucideIcons.pause : LucideIcons.play,
              color: foreground,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 6,
                    backgroundColor: foreground.withAlpha(50),
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatAudioDuration(
                    _duration == Duration.zero ? _position : _duration,
                  ),
                  style: TextStyle(
                    color: foreground.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoAttachmentMessage extends StatefulWidget {
  const _VideoAttachmentMessage({
    required this.attachmentUrl,
    required this.caption,
    required this.isMe,
  });

  final String? attachmentUrl;
  final String? caption;
  final bool isMe;

  @override
  State<_VideoAttachmentMessage> createState() =>
      _VideoAttachmentMessageState();
}

class _VideoAttachmentMessageState extends State<_VideoAttachmentMessage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  Future<void> _initializePreview() async {
    final resolvedUrl = resolveImageUrl(widget.attachmentUrl);
    if (resolvedUrl == null) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));
    try {
      await controller.initialize();
      await controller.pause();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
      });
    } catch (_) {
      await controller.dispose();
    }
  }

  void _openVideoPlayer() {
    final resolvedUrl = resolveImageUrl(widget.attachmentUrl);
    if (resolvedUrl == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VideoPlayerScreen(
          videoUrl: resolvedUrl,
          title: widget.caption ?? 'Video',
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return GestureDetector(
      onTap: _openVideoPlayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (controller != null && controller.value.isInitialized)
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 220,
                    height: 220,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.video,
                      color: AppColors.textSecondary,
                      size: 34,
                    ),
                  ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.play,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          if (widget.caption != null && widget.caption!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              widget.caption!,
              style: TextStyle(
                color: widget.isMe
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  const _VideoPlayerScreen({required this.videoUrl, required this.title});

  final String videoUrl;
  final String title;

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    await _controller.play();
    if (!mounted) return;
    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: !_initialized
            ? const CircularProgressIndicator(color: Colors.white)
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () async {
                        if (_controller.value.isPlaying) {
                          await _controller.pause();
                        } else {
                          await _controller.play();
                        }
                        if (!mounted) return;
                        setState(() {});
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Icon(
                          _controller.value.isPlaying
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          color: Colors.white,
                          size: 54,
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

String _formatAudioDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
