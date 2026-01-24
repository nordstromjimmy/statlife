import 'package:flutter/material.dart';
import '../../../core/utils/time_utils.dart';
import '../../../domain/models/task.dart';
import 'current_time_line.dart';
import 'hour_lines.dart';
import 'task_block.dart';

class Timeline extends StatefulWidget {
  const Timeline({
    super.key,
    required this.day,
    required this.now,
    required this.hourHeight,
    required this.gridLineOffset,
    required this.tasks,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onResizeCommit,
  });

  final DateTime day;
  final DateTime now;
  final double hourHeight;
  final double gridLineOffset;
  final List<Task> tasks;
  final Future<void> Function(Task task, bool checked) onToggleComplete;
  final void Function(Task task) onEdit;
  final Future<void> Function(Task updatedTask) onResizeCommit;

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    final totalHeight = 24 * widget.hourHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                // hour lines + labels
                for (var h = 0; h <= 24; h++)
                  HourLine(
                    hour: h,
                    top: h * widget.hourHeight,
                    lineOffset: widget.gridLineOffset,
                  ),
                for (var h = 0; h < 24; h++)
                  HalfHourLine(
                    top:
                        h * widget.hourHeight +
                        widget.gridLineOffset +
                        widget.hourHeight / 2,
                  ),

                // tasks
                for (final t in widget.tasks)
                  TaskBlock(
                    task: t,
                    hourHeight: widget.hourHeight,
                    gridLineOffset: widget.gridLineOffset,

                    onToggleComplete: widget.onToggleComplete,
                    onEdit: widget.onEdit,
                  ),

                if (isSameDay(widget.now, widget.day))
                  CurrentTimeLine(
                    now: widget.now,
                    hourHeight: widget.hourHeight,
                    gridLineOffset: widget.gridLineOffset,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
