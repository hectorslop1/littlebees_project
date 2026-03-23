import '../../../shared/models/message_model.dart';

class ParsedCallLog {
  const ParsedCallLog({
    required this.callType,
    required this.callerId,
    required this.durationSeconds,
    required this.status,
  });

  final String callType;
  final String callerId;
  final int durationSeconds;
  final String status;

  bool get isVideo => callType == 'video';
}

ParsedCallLog? parseCallLog(Message message) {
  if (message.attachmentType != 'call_log') {
    return null;
  }

  final parts = message.content.split('|');
  if (parts.length < 4) {
    return null;
  }

  return ParsedCallLog(
    callType: parts[0],
    callerId: parts[1],
    status: parts[2],
    durationSeconds: int.tryParse(parts[3]) ?? 0,
  );
}

String encodeCallLog({
  required String callType,
  required String callerId,
  required String status,
  required int durationSeconds,
}) {
  return '$callType|$callerId|$status|$durationSeconds';
}

String buildCallTitle(ParsedCallLog callLog, String currentUserId) {
  final isOutgoing = callLog.callerId == currentUserId;
  final base = callLog.isVideo ? 'Videollamada' : 'Llamada';

  switch (callLog.status) {
    case 'completed':
      return '$base ${isOutgoing ? 'saliente' : 'entrante'}';
    case 'declined':
      return isOutgoing ? 'Llamada rechazada' : 'Llamada declinada';
    case 'missed':
      return isOutgoing ? 'Llamada sin respuesta' : 'Llamada perdida';
    case 'cancelled':
      return 'Llamada cancelada';
    default:
      return base;
  }
}

String formatCallDuration(int durationSeconds) {
  final safeSeconds = durationSeconds < 0 ? 0 : durationSeconds;
  final minutes = safeSeconds ~/ 60;
  final seconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String buildCallSubtitle(ParsedCallLog callLog) {
  if (callLog.durationSeconds <= 0) {
    switch (callLog.status) {
      case 'declined':
        return 'No contestada';
      case 'missed':
        return 'Perdida';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Sin duracion';
    }
  }

  return 'Duracion ${formatCallDuration(callLog.durationSeconds)}';
}
