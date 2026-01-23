import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/goals/goal_controller.dart';
import '../../domain/models/goal.dart';

/// Shows a bottom sheet for adding or editing a goal
Future<void> showGoalFormSheet({
  required BuildContext context,
  required WidgetRef ref,
  Goal? existingGoal,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _GoalFormSheet(existingGoal: existingGoal),
  );
}

class _GoalFormSheet extends ConsumerStatefulWidget {
  const _GoalFormSheet({this.existingGoal});

  final Goal? existingGoal;

  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  late final TextEditingController _titleController;
  late int _minutes;

  bool _validate = false;

  bool get _isEditMode => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      // Edit mode: populate from existing goal
      _titleController = TextEditingController(
        text: widget.existingGoal!.title,
      );
      _minutes = widget.existingGoal!.defaultDurationMinutes;
    } else {
      // Add mode: initialize with defaults
      _titleController = TextEditingController();
      _minutes = 30;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _incrementMinutes() {
    setState(() {
      _minutes = (_minutes + 5).clamp(5, 600);
    });
  }

  void _decrementMinutes() {
    if (_minutes > 5) {
      setState(() {
        _minutes = (_minutes - 5).clamp(5, 600);
      });
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _validate = true;
      });
      return;
    }

    setState(() {
      _validate = false;
    });

    if (_isEditMode) {
      final updated = widget.existingGoal!.copyWith(
        title: title,
        defaultDurationMinutes: _minutes,
        updatedAt: DateTime.now(),
      );

      await ref.read(goalControllerProvider.notifier).upsert(updated);
    } else {
      await ref
          .read(goalControllerProvider.notifier)
          .create(title: title, defaultDurationMinutes: _minutes);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal?'),
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
        .read(goalControllerProvider.notifier)
        .delete(widget.existingGoal!.id);
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
          // Title field
          TextField(
            controller: _titleController,
            onChanged: (value) {
              if (_validate && value.trim().isNotEmpty) {
                setState(() {
                  _validate = false;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Goal title',
              hintText: _isEditMode ? null : 'e.g. Read this book',
              errorText: _validate ? 'Title cannot be empty' : null,
            ),
          ),
          const SizedBox(height: 12),

          // Default duration selector
          Row(
            children: [
              Text(
                'Default duration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: _minutes > 5 ? _decrementMinutes : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_minutes min',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: _incrementMinutes,
                icon: const Icon(Icons.add),
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
                  child: Text(_isEditMode ? 'Save changes' : 'Add goal'),
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
                    label: const Text('Delete goal'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
