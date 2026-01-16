import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile/profile_controller.dart';
import '../../application/tasks/task_controller.dart';
import '../../core/constants/times.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/models/task.dart';
import '../widgets/time_button.dart';

Future<void> showEditTaskSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime day,
  Task task,
) async {
  final titleController = TextEditingController(text: task.title);

  var start = task.startAt ?? DateTime(day.year, day.month, day.day, 0, 0);
  var end = task.endAt ?? start.add(const Duration(minutes: 30));
  var xp = task.xp;

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
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TimeButton(
                        label: 'Start',
                        time: start,
                        onTap: () async {
                          final picked = await pickTime(context, start);
                          if (picked == null) return;
                          final nextStart = DateTime(
                            day.year,
                            day.month,
                            day.day,
                            picked.hour,
                            picked.minute,
                          );
                          final snapped = roundToStep(
                            nextStart,
                            timeStepMinutes,
                          );

                          setState(() {
                            start = snapped;
                            if (!end.isAfter(start)) {
                              end = start.add(
                                const Duration(minutes: minTaskMinutes),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TimeButton(
                        label: 'End',
                        time: end,
                        onTap: () async {
                          final picked = await pickTime(context, end);
                          if (picked == null) return;
                          final nextEnd = DateTime(
                            day.year,
                            day.month,
                            day.day,
                            picked.hour,
                            picked.minute,
                          );
                          final snapped = roundToStep(nextEnd, timeStepMinutes);

                          setState(() {
                            end = snapped;
                            if (!end.isAfter(start)) {
                              end = start.add(
                                const Duration(minutes: minTaskMinutes),
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // XP stepper
                Row(
                  children: [
                    Text('XP', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      onPressed: xp > 0
                          ? () => setState(() => xp = (xp - 5).clamp(0, 9999))
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$xp', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      onPressed: () =>
                          setState(() => xp = (xp + 5).clamp(0, 9999)),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Complete toggle (and XP behavior)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final checked = !task.isCompleted;
                          final updated = task.copyWith(
                            title: titleController.text.trim().isEmpty
                                ? task.title
                                : titleController.text.trim(),
                            startAt: start,
                            endAt: end,
                            xp: xp,
                            completedAt: checked ? DateTime.now() : null,
                            updatedAt: DateTime.now(),
                          );

                          await ref
                              .read(taskControllerProvider.notifier)
                              .upsert(updated);

                          // Award XP only when newly completed
                          if (checked && !task.isCompleted) {
                            await ref
                                .read(profileControllerProvider.notifier)
                                .addXp(updated.xp);
                          }

                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                        label: Text(
                          task.isCompleted
                              ? 'Mark incomplete'
                              : 'Mark complete',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final updated = task.copyWith(
                            title: title.isEmpty ? task.title : title,
                            startAt: start,
                            endAt: end,
                            xp: xp,
                            updatedAt: DateTime.now(),
                          );

                          await ref
                              .read(taskControllerProvider.notifier)
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
                              title: const Text('Delete task?'),
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
                              .read(taskControllerProvider.notifier)
                              .delete(task.id);

                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete task'),
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
