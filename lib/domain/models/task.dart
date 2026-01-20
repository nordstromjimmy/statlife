import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required DateTime day,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
    @Default(10) int xp,
    @JsonKey(name: 'goal_id') String? goalId,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'first_completed_at') DateTime? firstCompletedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

extension TaskX on Task {
  bool get isCompleted => completedAt != null;
  bool get hasTimeSpan => startAt != null && endAt != null;

  int get durationMinutes {
    if (!hasTimeSpan) return 30;
    return endAt!.difference(startAt!).inMinutes.clamp(1, 24 * 60);
  }
}
