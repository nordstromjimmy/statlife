import 'package:flutter/material.dart';
import '../../../domain/models/task.dart';

class TaskContent extends StatelessWidget {
  const TaskContent({
    super.key,
    required this.task,
    required this.start,
    required this.end,
  });

  final Task task;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final durationMin = end.difference(start).inMinutes;
    final showDetails = durationMin >= 90;

    if (!showDetails) {
      // < 90 min: title + time/xp row with safe truncation
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_fmtTime(start)} – ${_fmtTime(end)} · ${task.xp} XP',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      );
    }

    // >= 90 min: title + subtitle
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 1),
        Text(
          '${_fmtTime(start)} – ${_fmtTime(end)} · ${task.xp} XP',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  static String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
