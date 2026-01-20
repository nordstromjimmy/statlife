import 'package:flutter/material.dart';
import '../../../domain/models/task.dart';
import 'task_content.dart';

// FOR EXPANDING THE END TIME BY DRAGGING THE TASK BLOCK DOWN
class TaskBlock extends StatefulWidget {
  const TaskBlock({
    super.key,
    required this.task,
    required this.hourHeight,
    required this.gridLineOffset,
    required this.timeStepMinutes,
    required this.minTaskMinutes,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onResizeCommit,
    required this.onResizeStart,
    required this.onResizeEnd,
  });

  final Task task;
  final double hourHeight;
  final double gridLineOffset;
  final int timeStepMinutes;
  final int minTaskMinutes;

  final Future<void> Function(Task task, bool checked) onToggleComplete;
  final void Function(Task task) onEdit;
  final Future<void> Function(Task updatedTask) onResizeCommit;

  final VoidCallback onResizeStart;
  final VoidCallback onResizeEnd;

  @override
  State<TaskBlock> createState() => _TaskBlockState();
}

class _TaskBlockState extends State<TaskBlock> {
  DateTime? _dragEndAt; // live preview while dragging
  double _dragDy = 0.0; // pixel delta since drag start
  DateTime? _startEndAt; // end time at drag start

  DateTime get _start => widget.task.startAt ?? widget.task.day;
  DateTime get _end =>
      _dragEndAt ??
      (widget.task.endAt ?? _start.add(const Duration(minutes: 30)));

  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    final start = _start;
    final end = _end;

    final startMinutes = start.hour * 60 + start.minute;
    final duration = end.difference(start).inMinutes.clamp(1, 24 * 60);

    final top =
        (startMinutes / 60.0) * widget.hourHeight + widget.gridLineOffset;
    final rawHeight = (duration / 60.0) * widget.hourHeight;

    const minVisualHeight = 36.0;
    final height = rawHeight.clamp(minVisualHeight, 9999.0);

    final left = 56.0;
    final rightPadding = 1.0;

    final bg = widget.task.isCompleted
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6)
        : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4);

    return Positioned(
      top: top + 2,
      left: left,
      right: rightPadding,
      height: (height - 4).clamp(40.0, 9999.0),
      child: GestureDetector(
        onTap: _isResizing ? null : () => widget.onEdit(widget.task),
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
          child: Stack(
            children: [
              // CONTENT
              TaskContent(
                task: widget.task.copyWith(endAt: end),
                start: start,
                end: end,
                onToggleComplete: (checked) {
                  widget.onToggleComplete(widget.task, checked);
                },
              ),

              // RESIZE HANDLE (bottom)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 32,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) {
                      // 🔒 lock scroll immediately, before gesture arena picks scroll
                      widget.onResizeStart();
                    },
                    onPointerUp: (_) {
                      // we also unlock here as a safety, actual unlock still happens in pan end/cancel
                      // (optional)
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (_) {
                        _dragDy = 0.0;
                        _startEndAt =
                            widget.task.endAt ??
                            _start.add(const Duration(minutes: 30));
                        setState(() {
                          _isResizing = true;
                          _dragEndAt = _startEndAt;
                        });
                      },
                      onPanUpdate: (details) {
                        _dragDy += details.delta.dy;
                        final deltaMinutes =
                            (_dragDy / widget.hourHeight) * 60.0;
                        final snappedDelta = _snapMinutes(
                          deltaMinutes.round(),
                          widget.timeStepMinutes,
                        );

                        final proposed = (_startEndAt ?? _end).add(
                          Duration(minutes: snappedDelta),
                        );
                        final clamped = _clampEnd(
                          start: _start,
                          proposedEnd: proposed,
                          minMinutes: widget.minTaskMinutes,
                        );

                        setState(() {
                          _dragEndAt = clamped;
                        });
                      },
                      onPanEnd: (_) async {
                        final newEnd = _dragEndAt;
                        _startEndAt = null;
                        _dragDy = 0.0;

                        if (newEnd == null) {
                          setState(() => _isResizing = false);
                          widget.onResizeEnd();
                          return;
                        }

                        final updated = widget.task.copyWith(
                          endAt: newEnd,
                          updatedAt: DateTime.now(),
                        );

                        setState(() {
                          _isResizing = false;
                          _dragEndAt = null;
                        });

                        widget.onResizeEnd();
                        await widget.onResizeCommit(updated);
                      },
                      onPanCancel: () {
                        setState(() {
                          _isResizing = false;
                          _dragEndAt = null;
                        });
                        _startEndAt = null;
                        _dragDy = 0.0;
                        widget.onResizeEnd();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 8,
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: _isResizing ? 0.10 : 0.0,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _isResizing
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _snapMinutes(int minutes, int step) {
    if (step <= 1) return minutes;
    final snapped = (minutes / step).round() * step;
    return snapped;
  }

  DateTime _clampEnd({
    required DateTime start,
    required DateTime proposedEnd,
    required int minMinutes,
  }) {
    // Min duration clamp
    final minEnd = start.add(Duration(minutes: minMinutes));

    // End-of-day clamp (24:00)
    final dayEnd = DateTime(
      start.year,
      start.month,
      start.day,
    ).add(const Duration(hours: 24));

    var end = proposedEnd;

    if (end.isBefore(minEnd)) end = minEnd;
    if (end.isAfter(dayEnd)) end = dayEnd;

    // Snap end time to stepMinutes as well (strong guarantee)
    end = _snapDateTimeToStep(end, widget.timeStepMinutes);

    // Re-apply min duration after snapping (in case snap pulled it below min)
    if (end.isBefore(minEnd)) end = minEnd;

    return end;
  }

  DateTime _snapDateTimeToStep(DateTime dt, int stepMinutes) {
    final total = dt.hour * 60 + dt.minute;
    final snapped = (total / stepMinutes).round() * stepMinutes;

    var h = snapped ~/ 60;
    var m = snapped % 60;

    // handle 24:00 edge case
    if (h >= 24) {
      h = 23;
      m = 59;
    }

    return DateTime(dt.year, dt.month, dt.day, h, m);
  }
}
