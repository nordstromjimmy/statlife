import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    Spacer(),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
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
