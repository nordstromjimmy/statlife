import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/tasks/task_controller.dart';
import '../../../core/utils/time_utils.dart';
import '../../../domain/models/task.dart';

class WeekView extends ConsumerWidget {
  const WeekView({
    super.key,
    required this.anchor,
    required this.tasks,
    required this.onPickDay,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime anchor;
  final List<Task> tasks;
  final void Function(DateTime day) onPickDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = _startOfWeek(anchor); // Monday
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    final label =
        '${DateFormat('d MMM').format(days.first)} – ${DateFormat('d MMM').format(days.last)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final day = days[i];

              final dayTasks = tasks
                  .where((t) => isSameDay(t.day, day))
                  .toList();
              final completed = dayTasks.where((t) => t.isCompleted).length;
              final today = isToday(day);
              final theme = Theme.of(context);

              return GestureDetector(
                // Long press to copy tasks
                onLongPress: dayTasks.isEmpty
                    ? null
                    : () {
                        _showCopyTasksDialog(
                          context,
                          ref,
                          sourceDay: day,
                          sourceTasks: dayTasks,
                          allDays: days,
                        );
                      },
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onPickDay(day),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: today
                          ? theme.colorScheme.secondary.withValues(alpha: 0.5)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: today
                            ? theme.colorScheme.primary.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.06),
                        width: today ? 1.2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEE').format(day),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white60),
                              ),
                              Text(
                                DateFormat('d MMM').format(day),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${dayTasks.length} tasks • $completed done',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static DateTime _startOfWeek(DateTime d) {
    // Monday = 1
    final delta = d.weekday - DateTime.monday;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: delta));
  }

  // Moved inside the class as an instance method
  void _showCopyTasksDialog(
    BuildContext context,
    WidgetRef ref, {
    required DateTime sourceDay,
    required List<Task> sourceTasks,
    required List<DateTime> allDays,
  }) {
    showDialog(
      context: context,
      builder: (context) => _CopyTasksDialog(
        sourceDay: sourceDay,
        sourceTasks: sourceTasks,
        availableDays: allDays.where((d) => !isSameDay(d, sourceDay)).toList(),
        onCopy: (selectedTasks, selectedDays) async {
          // Now receives only the selected tasks
          await ref
              .read(taskControllerProvider.notifier)
              .copyTasksToDays(selectedTasks, selectedDays);

          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Copied ${selectedTasks.length} tasks to ${selectedDays.length} days',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}

class _CopyTasksDialog extends StatefulWidget {
  const _CopyTasksDialog({
    required this.sourceDay,
    required this.sourceTasks,
    required this.availableDays,
    required this.onCopy,
  });

  final DateTime sourceDay;
  final List<Task> sourceTasks;
  final List<DateTime> availableDays;
  final Future<void> Function(
    List<Task> selectedTasks,
    List<DateTime> selectedDays,
  )
  onCopy;

  @override
  State<_CopyTasksDialog> createState() => _CopyTasksDialogState();
}

class _CopyTasksDialogState extends State<_CopyTasksDialog> {
  final Set<DateTime> _selectedDays = {};
  late final Set<String> _selectedTaskIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with all tasks selected
    _selectedTaskIds = widget.sourceTasks.map((t) => t.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasksCount = _selectedTaskIds.length;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Copy tasks', style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From ${DateFormat('EEEE, MMM d').format(widget.sourceDay)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),

            // Task selection section
            Row(
              children: [
                Text(
                  'Select tasks to copy:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            if (_selectedTaskIds.length ==
                                widget.sourceTasks.length) {
                              // Deselect all
                              _selectedTaskIds.clear();
                            } else {
                              // Select all
                              _selectedTaskIds.addAll(
                                widget.sourceTasks.map((t) => t.id),
                              );
                            }
                          });
                        },
                  child: Text(
                    _selectedTaskIds.length == widget.sourceTasks.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Show task list with checkboxes
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.sourceTasks.map((task) {
                  final isSelected = _selectedTaskIds.contains(task.id);
                  return InkWell(
                    onTap: _isLoading
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                _selectedTaskIds.remove(task.id);
                              } else {
                                _selectedTaskIds.add(task.id);
                              }
                            });
                          },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: _isLoading
                                ? null
                                : (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedTaskIds.add(task.id);
                                      } else {
                                        _selectedTaskIds.remove(task.id);
                                      }
                                    });
                                  },
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? null : Colors.white54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            Text('Copy to:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),

            // Day checkboxes
            ...widget.availableDays.map((day) {
              final isDaySelected = _selectedDays.contains(day);
              return CheckboxListTile(
                value: isDaySelected,
                onChanged: _isLoading
                    ? null
                    : (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                title: Text(
                  DateFormat('EEEE, MMM d').format(day),
                  style: const TextStyle(fontSize: 15),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            FilledButton(
              onPressed:
                  _selectedDays.isEmpty ||
                      _selectedTaskIds.isEmpty ||
                      _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);

                      // Filter to only selected tasks
                      final selectedTasks = widget.sourceTasks
                          .where((t) => _selectedTaskIds.contains(t.id))
                          .toList();

                      await widget.onCopy(
                        selectedTasks,
                        _selectedDays.toList(),
                      );
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      selectedTasksCount > 0
                          ? 'Copy $selectedTasksCount to ${_selectedDays.length}'
                          : 'Select tasks',
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
