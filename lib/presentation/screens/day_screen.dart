import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../application/profile/profile_controller.dart';
import '../../application/tasks/task_controller.dart';
import '../../domain/logic/leveling.dart';
import '../../domain/models/task.dart';

class DayScreen extends ConsumerWidget {
  const DayScreen({super.key});

  static const _hourHeight = 64.0; // pixels per hour (tweak later)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final dateLabel = DateFormat(
      'EEEE, d MMM',
    ).format(day); // e.g. Thursday, 15 Jan

    return Scaffold(
      appBar: AppBar(title: Text(dateLabel)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context, ref, day),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsync.when(
              data: (profile) {
                final computed = computeLevelFromTotalXp(profile.totalXp);
                final progress = computed.xpIntoLevel / computed.xpForNext;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${computed.level}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${computed.xpIntoLevel} / ${computed.xpForNext} XP to next level',
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Profile error: $e'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final dayTasks = tasks
                      .where((t) => _isSameDay(t.day, day))
                      .toList();

                  return _Timeline(
                    day: day,
                    hourHeight: _hourHeight,
                    tasks: dayTasks,
                    onToggleComplete: (task, checked) async {
                      final updated = task.copyWith(
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
                            .addXp(task.xp);
                      }
                    },
                    onEdit: (task) =>
                        _showEditTaskSheet(context, ref, day, task),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Tasks error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTaskSheet(
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
                        child: _TimeButton(
                          label: 'Start',
                          time: start,
                          onTap: () async {
                            final picked = await _pickTime(context, start);
                            if (picked == null) return;
                            final nextStart = DateTime(
                              day.year,
                              day.month,
                              day.day,
                              picked.hour,
                              picked.minute,
                            );
                            final snapped = _roundTo30(nextStart);

                            setState(() {
                              start = snapped;
                              if (!end.isAfter(start)) {
                                end = start.add(const Duration(minutes: 30));
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeButton(
                          label: 'End',
                          time: end,
                          onTap: () async {
                            final picked = await _pickTime(context, end);
                            if (picked == null) return;
                            final nextEnd = DateTime(
                              day.year,
                              day.month,
                              day.day,
                              picked.hour,
                              picked.minute,
                            );
                            final snapped = _roundTo30(nextEnd);

                            setState(() {
                              end = snapped;
                              if (!end.isAfter(start)) {
                                end = start.add(const Duration(minutes: 30));
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
                      Text(
                        'XP',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: xp > 0
                            ? () => setState(() => xp = (xp - 5).clamp(0, 9999))
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$xp',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
                          icon: Icon(
                            task.isCompleted ? Icons.undo : Icons.check,
                          ),
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
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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

  Future<void> _showAddTaskSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
  ) async {
    final titleController = TextEditingController();

    // Default span: now rounded to nearest 30 min → +30 min
    final now = DateTime.now();
    final rounded = _roundTo30(
      DateTime(day.year, day.month, day.day, now.hour, now.minute),
    );
    var start = rounded;
    var end = rounded.add(const Duration(minutes: 30));

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
                        child: _TimeButton(
                          label: 'Start',
                          time: start,
                          onTap: () async {
                            final picked = await _pickTime(context, start);
                            if (picked == null) return;
                            final nextStart = DateTime(
                              day.year,
                              day.month,
                              day.day,
                              picked.hour,
                              picked.minute,
                            );
                            final snapped = _roundTo30(nextStart);

                            setState(() {
                              start = snapped;
                              if (!end.isAfter(start)) {
                                end = start.add(const Duration(minutes: 30));
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeButton(
                          label: 'End',
                          time: end,
                          onTap: () async {
                            final picked = await _pickTime(context, end);
                            if (picked == null) return;
                            final nextEnd = DateTime(
                              day.year,
                              day.month,
                              day.day,
                              picked.hour,
                              picked.minute,
                            );
                            final snapped = _roundTo30(nextEnd);

                            setState(() {
                              end = snapped;
                              if (!end.isAfter(start)) {
                                end = start.add(const Duration(minutes: 30));
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

  static Future<TimeOfDay?> _pickTime(BuildContext context, DateTime initial) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
  }

  static DateTime _roundTo30(DateTime dt) {
    final minute = dt.minute;
    final snapped = (minute / 30).round() * 30;
    var rounded = DateTime(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      0,
    ).add(Duration(minutes: snapped));
    // handle 60 snap
    if (rounded.minute == 60) {
      rounded = DateTime(dt.year, dt.month, dt.day, dt.hour + 1, 0);
    }
    return rounded;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.day,
    required this.hourHeight,
    required this.tasks,
    required this.onToggleComplete,
    required this.onEdit,
  });

  final DateTime day;
  final double hourHeight;
  final List<Task> tasks;
  final Future<void> Function(Task task, bool checked) onToggleComplete;
  final void Function(Task task) onEdit;

  static const _gridLineOffset =
      10.0; // where the hour divider is drawn within the hour row

  @override
  Widget build(BuildContext context) {
    final totalHeight = 24 * hourHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                // hour lines + labels
                for (var h = 0; h <= 24; h++)
                  _HourLine(
                    hour: h,
                    top: h * hourHeight,
                    lineOffset: _gridLineOffset,
                  ),
                for (var h = 0; h < 24; h++)
                  _HalfHourLine(top: h * hourHeight + hourHeight / 2),
                // tasks
                for (final t in tasks)
                  _TaskBlock(
                    task: t,
                    hourHeight: hourHeight,
                    onToggleComplete: onToggleComplete,
                    onEdit: onEdit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HalfHourLine extends StatelessWidget {
  const _HalfHourLine({required this.top});
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 76,
      right: 0,
      top: top,
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.04),
      ),
    );
  }
}

class _HourLine extends StatelessWidget {
  const _HourLine({
    required this.hour,
    required this.top,
    required this.lineOffset,
  });
  final int hour;
  final double top;
  final double lineOffset;

  @override
  Widget build(BuildContext context) {
    final label = '${hour.toString().padLeft(2, '0')}:00';

    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: SizedBox(
        height: 22, // ✅ enough for text
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 2),
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: lineOffset), // line sits mid-row
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskBlock extends StatelessWidget {
  const _TaskBlock({
    required this.task,
    required this.hourHeight,
    required this.onToggleComplete,
    required this.onEdit,
  });

  final Task task;
  final double hourHeight;
  final Future<void> Function(Task task, bool checked) onToggleComplete;
  final void Function(Task task) onEdit;

  static const _gridLineOffset = 10.0;

  @override
  Widget build(BuildContext context) {
    final start = task.startAt ?? task.day;
    final end = task.endAt ?? start.add(const Duration(minutes: 30));

    final startMinutes = start.hour * 60 + start.minute;
    final duration = end.difference(start).inMinutes.clamp(15, 24 * 60);
    final top = (startMinutes / 60.0) * hourHeight + _gridLineOffset;
    final rawHeight = (duration / 60.0) * hourHeight;
    final height = rawHeight.clamp(44.0, 9999.0); // min height for content+taps

    final left = 58.0; // after hour labels
    final rightPadding = 4.0;

    final bg = task.isCompleted
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.14);

    return Positioned(
      top: top + 2,
      left: left,
      right: rightPadding,
      height: (height - 4).clamp(40.0, 9999.0),
      child: GestureDetector(
        onTap: () => onEdit(task),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final start = task.startAt ?? task.day;
              final end = task.endAt ?? start.add(const Duration(minutes: 30));
              final durationMin = end.difference(start).inMinutes;

              final showDetails = durationMin >= 60;

              if (!showDetails) {
                // < 60 min: TITLE ONLY (single line) — avoids overflow entirely
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              }

              // >= 60 min: TITLE + SUBTITLE
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize
                          .min, // important: don't try to fill height
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmtTime(start)} – ${_fmtTime(end)} · ${task.xp} XP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final DateTime time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
