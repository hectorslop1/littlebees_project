import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../design_system/theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../application/ai_assistant_provider.dart';
import '../application/ai_voice_provider.dart';
import '../domain/ai_voice_models.dart';
import 'widgets/beea_voice_orb.dart';

class AiVoiceSessionScreen extends ConsumerStatefulWidget {
  const AiVoiceSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<AiVoiceSessionScreen> createState() =>
      _AiVoiceSessionScreenState();
}

class _AiVoiceSessionScreenState extends ConsumerState<AiVoiceSessionScreen> {
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(aiVoiceProvider.notifier).start(widget.sessionId);
    });
  }

  Future<void> _closeVoiceMode() async {
    if (_isClosing) return;
    _isClosing = true;

    try {
      final session = await ref.read(aiVoiceProvider.notifier).end();
      if (session != null && mounted) {
        await ref.read(aiAssistantProvider.notifier).reloadSession(session.id);
      }
    } finally {
      ref.read(aiVoiceProvider.notifier).reset();
    }

    if (mounted) {
      context.goNamed(RouteNames.aiAssistant);
    }
  }

  Future<void> _showVoiceSettings() async {
    final notifier = ref.read(aiVoiceProvider.notifier);
    final state = ref.read(aiVoiceProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColor(AppColors.surface),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voz de Beea',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'La voz seleccionada se aplicara en la siguiente conversacion.',
                  style: TextStyle(
                    color: context.appColor(AppColors.textSecondary),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ...state.presets.map(
                  (preset) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        notifier.selectPreset(preset.id);
                        Navigator.of(context).pop();
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: preset.id == state.selectedPresetId
                              ? AppColors.primarySurface
                              : context.appColor(AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: preset.id == state.selectedPresetId
                                ? AppColors.primary
                                : context.appColor(AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              preset.id == state.selectedPresetId
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.volume2,
                              color: preset.id == state.selectedPresetId
                                  ? AppColors.primary
                                  : context.appColor(AppColors.textSecondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    preset.subtitle,
                                    style: TextStyle(
                                      color: context.appColor(
                                        AppColors.textSecondary,
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiVoiceProvider);
    final orbAmplitude = switch (state.status) {
      AiVoiceSessionStatus.speaking => state.remoteLevel,
      AiVoiceSessionStatus.processing => 0.22,
      AiVoiceSessionStatus.listening => state.localLevel,
      AiVoiceSessionStatus.connecting => 0.12,
      _ => 0.08,
    }.clamp(0.0, 1.0);
    final themeText = context.appColor(AppColors.textPrimary);
    final secondaryText = context.appColor(AppColors.textSecondary);
    final selectedPreset = state.selectedPreset;
    final remoteRenderer = ref
        .read(aiVoiceProvider.notifier)
        .remoteAudioRenderer;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) async {
        await _closeVoiceMode();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(
                  children: [
                    _RoundIconButton(
                      icon: LucideIcons.chevronLeft,
                      onTap: _closeVoiceMode,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Conversando con Beea',
                            style: TextStyle(
                              color: themeText,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedPreset.label,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RoundIconButton(
                      icon: LucideIcons.slidersHorizontal,
                      onTap: _showVoiceSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    RepaintBoundary(
                      child: BeeaVoiceOrb(
                        status: state.status,
                        amplitude: orbAmplitude,
                        size: 224,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AnimatedOpacity(
                        opacity: state.visibleTranscript.isEmpty ? 0.6 : 1,
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          state.visibleTranscript,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeText.withValues(alpha: 0.72),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _statusLabel(state.status),
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _VoiceActionButton(
                      backgroundColor: const Color(0xFFFFEEF0),
                      foregroundColor: const Color(0xFFD85A67),
                      icon: state.isMicMuted
                          ? LucideIcons.micOff
                          : LucideIcons.mic,
                      label: state.isMicMuted ? 'Activar' : 'Silenciar',
                      onTap: () =>
                          ref.read(aiVoiceProvider.notifier).toggleMic(),
                    ),
                    _VoiceActionButton(
                      backgroundColor: Colors.white,
                      foregroundColor: themeText,
                      icon: LucideIcons.x,
                      label: 'Terminar',
                      onTap: _closeVoiceMode,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 1,
                height: 1,
                child: RTCVideoView(remoteRenderer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(AiVoiceSessionStatus status) {
    return switch (status) {
      AiVoiceSessionStatus.connecting => 'Conectando voz...',
      AiVoiceSessionStatus.listening => 'Escuchando',
      AiVoiceSessionStatus.processing => 'Procesando',
      AiVoiceSessionStatus.speaking => 'Respondiendo',
      AiVoiceSessionStatus.ending => 'Guardando conversacion...',
      AiVoiceSessionStatus.error => 'Ocurrio un problema',
      _ => 'Listo',
    };
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: context.appColor(AppColors.textPrimary)),
        ),
      ),
    );
  }
}

class _VoiceActionButton extends StatelessWidget {
  const _VoiceActionButton({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 68,
              height: 68,
              child: Icon(icon, color: foregroundColor, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: context.appColor(AppColors.textSecondary),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
