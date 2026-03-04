import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_summary.freezed.dart';
part 'ai_summary.g.dart';

@freezed
class AiSummary with _$AiSummary {
  const factory AiSummary({
    required String emoji,
    required String headline,
    required List<String> bullets,
    required DateTime generatedAt,
  }) = _AiSummary;

  factory AiSummary.fromJson(Map<String, dynamic> json) => _$AiSummaryFromJson(json);
}
