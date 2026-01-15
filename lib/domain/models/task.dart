import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,

    /// Calendar day this task belongs to (date-only usage in UI)
    required DateTime day,

    /// Timed span (required going forward). Old tasks may be null until migrated.
    DateTime? startAt,
    DateTime? endAt,

    /// XP granted when completed
    @Default(10) int xp,

    /// null = not completed
    DateTime? completedAt,

    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

extension TaskX on Task {
  bool get isCompleted => completedAt != null;

  bool get hasTimeSpan => startAt != null && endAt != null;

  /// Duration in minutes (safe default if missing)
  int get durationMinutes {
    if (!hasTimeSpan) return 30;
    return endAt!.difference(startAt!).inMinutes.clamp(1, 24 * 60);
  }
}
