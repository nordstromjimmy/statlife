import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/time_utils.dart';
import '../../../domain/models/task.dart';

class WeekView extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

              return InkWell(
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
}
