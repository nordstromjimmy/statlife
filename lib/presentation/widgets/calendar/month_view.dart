import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/time_utils.dart';
import '../../../domain/models/task.dart';

class MonthView extends StatelessWidget {
  const MonthView({
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
    final first = DateTime(anchor.year, anchor.month, 1);
    final label = DateFormat('MMMM yyyy').format(first);

    // Build a simple month grid starting Monday
    final start = first.subtract(
      Duration(days: (first.weekday - DateTime.monday) % 7),
    );
    final days = List.generate(42, (i) => start.add(Duration(days: i)));

    return Column(
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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final inMonth = day.month == first.month;
              final today = isToday(day);
              final theme = Theme.of(context);

              return InkWell(
                onTap: () => onPickDay(day),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: today
                        ? theme.colorScheme.primary.withValues(alpha: 0.44)
                        : inMonth
                        ? theme.colorScheme.surface
                        : theme.colorScheme.surface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: today
                          ? theme.colorScheme.primary.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.06),
                      width: today ? 1.4 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.day}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: today
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: today
                              ? theme.colorScheme.primary
                              : inMonth
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
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
}
