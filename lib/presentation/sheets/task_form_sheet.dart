import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../application/goals/goal_controller.dart';
import '../../application/tasks/task_controller.dart';
import '../../core/constants/times.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/logic/xp_generator.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/task.dart';
import '../widgets/time_button.dart';

/// Shows a bottom sheet for adding or editing a task
Future<void> showTaskFormSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime day, {
  Task? existingTask,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _TaskFormSheet(day: day, existingTask: existingTask),
  );
}

class _TaskFormSheet extends ConsumerStatefulWidget {
  const _TaskFormSheet({required this.day, this.existingTask});

  final DateTime day;
  final Task? existingTask;

  @override
  ConsumerState<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  late final TextEditingController _titleController;
  late DateTime _start;
  late DateTime _end;
  late int _xp;
  Goal? _selectedGoal;

  bool get _isEditMode => widget.existingTask != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      // Edit mode: populate from existing task
      final task = widget.existingTask!;
      _titleController = TextEditingController(text: task.title);
      _start =
          task.startAt ??
          DateTime(widget.day.year, widget.day.month, widget.day.day, 0, 0);
      _end = task.endAt ?? _start.add(const Duration(minutes: minTaskMinutes));
      _xp = task.xp;
    } else {
      // Add mode: initialize with defaults
      _titleController = TextEditingController();
      _xp = XpGenerator.random(min: 50, max: 100);

      final now = DateTime.now();
      final rounded = roundToStep(
        DateTime(
          widget.day.year,
          widget.day.month,
          widget.day.day,
          now.hour,
          now.minute,
        ),
        timeStepMinutes,
      );
      _start = rounded;
      _end = rounded.add(const Duration(minutes: minTaskMinutes));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleGoalSelection(Goal? goal) {
    setState(() {
      _selectedGoal = goal;

      if (goal != null) {
        // Autofill title if empty
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = goal.title;
        }

        // Apply goal defaults
        _end = _start.add(Duration(minutes: goal.defaultDurationMinutes));
      }
    });
  }

  Future<void> _handleTimeChange({
    required bool isStart,
    required TimeOfDay picked,
  }) async {
    final newDateTime = DateTime(
      widget.day.year,
      widget.day.month,
      widget.day.day,
      picked.hour,
      picked.minute,
    );
    final snapped = roundToStep(newDateTime, timeStepMinutes);

    setState(() {
      if (isStart) {
        _start = snapped;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(minutes: minTaskMinutes));
        }
      } else {
        _end = snapped;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(minutes: minTaskMinutes));
        }
      }
    });
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final task = _isEditMode
        ? widget.existingTask!.copyWith(
            title: title,
            startAt: _start,
            endAt: _end,
            xp: _xp,
            updatedAt: now,
          )
        : Task(
            id: const Uuid().v4(),
            title: title,
            day: widget.day,
            startAt: _start,
            endAt: _end,
            xp: _xp,
            goalId: _selectedGoal?.id,
            completedAt: null,
            createdAt: now,
            updatedAt: now,
          );

    await ref.read(taskControllerProvider.notifier).upsert(task);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(taskControllerProvider.notifier)
        .delete(widget.existingTask!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Goal selection (only in add mode)
          if (!_isEditMode) _buildGoalSelector(),
          if (!_isEditMode) const SizedBox(height: 12),

          // Title field
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task title',
              hintText: 'e.g. Gym',
            ),
          ),
          const SizedBox(height: 12),

          // Time selectors
          Row(
            children: [
              Expanded(
                child: TimeButton(
                  label: 'Start',
                  time: _start,
                  onTap: () async {
                    final picked = await pickTime(context, _start);
                    if (picked == null) return;
                    await _handleTimeChange(isStart: true, picked: picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TimeButton(
                  label: 'End',
                  time: _end,
                  onTap: () async {
                    final picked = await pickTime(context, _end);
                    if (picked == null) return;
                    await _handleTimeChange(isStart: false, picked: picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Save button
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _handleSave,
                  child: Text(_isEditMode ? 'Save changes' : 'Add task'),
                ),
              ),
            ],
          ),

          // Delete button (only in edit mode)
          if (_isEditMode) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete task'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalSelector() {
    final goalsAsync = ref.watch(goalControllerProvider);

    return goalsAsync.when(
      data: (goals) {
        final activeGoals = goals.where((g) => g.archivedAt == null).toList();

        if (activeGoals.isEmpty) return const SizedBox.shrink();

        return DropdownButtonFormField<Goal>(
          decoration: const InputDecoration(labelText: 'From goal (optional)'),
          value: _selectedGoal,
          items: [
            const DropdownMenuItem<Goal>(value: null, child: Text('None')),
            ...activeGoals.map(
              (g) => DropdownMenuItem<Goal>(
                value: g,
                child: Text(g.title, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: _handleGoalSelection,
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
