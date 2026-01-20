import 'package:flutter/material.dart';
import '../../../domain/models/task.dart';

class TaskContent extends StatefulWidget {
  const TaskContent({
    super.key,
    required this.task,
    required this.start,
    required this.end,
    required this.onToggleComplete,
  });

  final Task task;
  final DateTime start;
  final DateTime end;
  final void Function(bool checked) onToggleComplete;

  @override
  State<TaskContent> createState() => _TaskContentState();
}

class _TaskContentState extends State<TaskContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.3),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.3, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
        );

    if (widget.task.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final durationMin = widget.end.difference(widget.start).inMinutes;
    final showDetails = durationMin >= 90;

    return Row(
      children: [
        // Animated Checkbox
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: () {
                  final newValue = !widget.task.isCompleted;
                  if (newValue) {
                    _checkController.forward();
                  } else {
                    _checkController.reverse();
                  }
                  widget.onToggleComplete(newValue);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.task.isCompleted
                          ? Colors.black
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    color: widget.task.isCompleted
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.transparent,
                  ),
                  child: widget.task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // Task Content
        Expanded(
          child: Opacity(
            opacity: widget.task.isCompleted ? 0.5 : 1.0,
            child: showDetails
                ? _buildDetailedContent(context)
                : _buildCompactContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            widget.task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              decoration: widget.task.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${_fmtTime(widget.start)} – ${_fmtTime(widget.end)} · ${widget.task.xp} XP',
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            decoration: widget.task.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            decoration: widget.task.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '${_fmtTime(widget.start)} – ${_fmtTime(widget.end)} · ${widget.task.xp} XP',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            decoration: widget.task.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
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
