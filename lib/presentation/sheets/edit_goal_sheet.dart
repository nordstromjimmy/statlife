import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/goals/goal_controller.dart';
import '../../domain/models/goal.dart';

Future<void> showEditGoalSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Goal goal,
}) async {
  final titleController = TextEditingController(text: goal.title);

  var minutes = goal.defaultDurationMinutes;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Goal title'),
                ),
                const SizedBox(height: 12),

                // Default duration
                Row(
                  children: [
                    Text(
                      'Default duration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: minutes > 5
                          ? () => setState(
                              () => minutes = (minutes - 5).clamp(5, 600),
                            )
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$minutes min',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => minutes = (minutes + 5).clamp(5, 600)),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Save
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          final updated = goal.copyWith(
                            title: title,
                            defaultDurationMinutes: minutes,
                            updatedAt: DateTime.now(),
                          );

                          await ref
                              .read(goalControllerProvider.notifier)
                              .upsert(updated);

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Save changes'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Delete
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete goal?'),
                              content: const Text('This cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;

                          await ref
                              .read(goalControllerProvider.notifier)
                              .delete(goal.id);

                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete goal'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
