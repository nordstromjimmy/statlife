import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../application/tasks/task_controller.dart';
import '../../core/constants/times.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/models/task.dart';
import '../widgets/time_button.dart';

Future<void> showAddTaskSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime day,
) async {
  final titleController = TextEditingController();

  // Default span: now rounded to nearest 30 min → +30 min
  final now = DateTime.now();
  final rounded = roundToStep(
    DateTime(day.year, day.month, day.day, now.hour, now.minute),
    timeStepMinutes,
  );
  var start = rounded;
  var end = rounded.add(const Duration(minutes: minTaskMinutes));

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
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'e.g. Gym',
                  ),
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
                          if (title.isEmpty) return;

                          final now = DateTime.now();
                          final task = Task(
                            id: const Uuid().v4(),
                            title: title,
                            day: day,
                            startAt: start,
                            endAt: end,
                            xp: 10,
                            completedAt: null,
                            createdAt: now,
                            updatedAt: now,
                          );

                          await ref
                              .read(taskControllerProvider.notifier)
                              .upsert(task);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Add task'),
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
