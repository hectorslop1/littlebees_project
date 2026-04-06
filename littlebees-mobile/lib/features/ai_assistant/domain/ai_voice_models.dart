enum AiVoiceSessionStatus {
  idle,
  connecting,
  listening,
  processing,
  speaking,
  ending,
  ended,
  error,
}

class AiVoicePreset {
  const AiVoicePreset({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.voice,
  });

  final String id;
  final String label;
  final String subtitle;
  final String voice;
}

class AiVoiceTranscriptTurn {
  const AiVoiceTranscriptTurn({
    required this.itemId,
    required this.role,
    required this.content,
    required this.isFinal,
    required this.updatedAt,
  });

  final String itemId;
  final String role;
  final String content;
  final bool isFinal;
  final DateTime updatedAt;

  AiVoiceTranscriptTurn copyWith({
    String? itemId,
    String? role,
    String? content,
    bool? isFinal,
    DateTime? updatedAt,
  }) {
    return AiVoiceTranscriptTurn(
      itemId: itemId ?? this.itemId,
      role: role ?? this.role,
      content: content ?? this.content,
      isFinal: isFinal ?? this.isFinal,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AiVoiceCallResponse {
  const AiVoiceCallResponse({
    required this.sdp,
    required this.voicePresetId,
    required this.voice,
  });

  final String sdp;
  final String voicePresetId;
  final String voice;

  factory AiVoiceCallResponse.fromJson(Map<String, dynamic> json) {
    return AiVoiceCallResponse(
      sdp: json['sdp'] as String,
      voicePresetId: json['voicePresetId'] as String,
      voice: json['voice'] as String,
    );
  }
}

const aiVoicePresets = <AiVoicePreset>[
  AiVoicePreset(
    id: 'calida',
    label: 'Calida',
    subtitle: 'Suave, cercana y acogedora',
    voice: 'shimmer',
  ),
  AiVoicePreset(
    id: 'clara',
    label: 'Clara',
    subtitle: 'Mas limpia y directa al hablar',
    voice: 'verse',
  ),
  AiVoicePreset(
    id: 'serena',
    label: 'Serena',
    subtitle: 'Tranquila, pausada y segura',
    voice: 'sage',
  ),
  AiVoicePreset(
    id: 'firme',
    label: 'Firme',
    subtitle: 'Con mas presencia y tono sobrio',
    voice: 'echo',
  ),
];
