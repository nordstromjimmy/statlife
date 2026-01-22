import 'package:flutter/material.dart';
import '../../../domain/models/task.dart';
import 'task_content.dart';

class TaskBlock extends StatelessWidget {
  const TaskBlock({
    super.key,
    required this.task,
    required this.hourHeight,
    required this.gridLineOffset,
    required this.onToggleComplete,
    required this.onEdit,
  });

  final Task task;
  final double hourHeight;
  final double gridLineOffset;

  final Future<void> Function(Task task, bool checked) onToggleComplete;
  final void Function(Task task) onEdit;

  @override
  Widget build(BuildContext context) {
    final start = task.startAt ?? task.day;
    final end = task.endAt ?? start.add(const Duration(minutes: 30));

    final startMinutes = start.hour * 60 + start.minute;
    final duration = end.difference(start).inMinutes.clamp(1, 24 * 60);

    final top = (startMinutes / 60.0) * hourHeight + gridLineOffset;
    final rawHeight = (duration / 60.0) * hourHeight;

    const minVisualHeight = 36.0;
    final height = rawHeight.clamp(minVisualHeight, 9999.0);

    const left = 56.0;
    const rightPadding = 1.0;

    final bg = task.isCompleted
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6)
        : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4);

    return Positioned(
      top: top + 2,
      left: left,
      right: rightPadding,
      height: (height - 4).clamp(40.0, 9999.0),
      child: GestureDetector(
        onTap: () => onEdit(task),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: TaskContent(
            task: task,
            start: start,
            end: end,
            onToggleComplete: (checked) {
              onToggleComplete(task, checked);
            },
          ),
        ),
      ),
    );
  }
}
