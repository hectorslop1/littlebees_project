import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/enums.dart';

part 'daily_log_model.freezed.dart';
part 'daily_log_model.g.dart';

@freezed
class DailyLogEntry with _$DailyLogEntry {
  const factory DailyLogEntry({
    required String id,
    required String tenantId,
    required String childId,
    required DateTime date,
    required LogType type,
    required String title,
    String? description,
    String? time,
    Map<String, dynamic>? metadata,
    String? recordedBy,
    String? recordedByName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DailyLogEntry;

  factory DailyLogEntry.fromJson(Map<String, dynamic> json) =>
      _$DailyLogEntryFromJson(json);
}
