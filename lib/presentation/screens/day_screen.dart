import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/profile/profile_controller.dart';
import '../../application/tasks/task_controller.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/models/task.dart';
import '../sheets/add_task_sheet.dart';
import '../sheets/edit_task_sheet.dart';
import '../widgets/timeline/day_timeline.dart';
import 'package:go_router/go_router.dart';

final nowProvider = StreamProvider<DateTime>((ref) async* {
  // Emit immediately, then every 30 seconds
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 30),
    (_) => DateTime.now(),
  );
});

class DayScreen extends ConsumerStatefulWidget {
  const DayScreen({super.key, this.initialDay});

  final DateTime? initialDay;

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  late DateTime selectedDay;
  static const _hourHeight = 64.0; // pixels per hour (tweak later)

  @override
  void initState() {
    super.initState();
    final base = widget.initialDay ?? DateTime.now();
    selectedDay = DateTime(base.year, base.month, base.day);
  }

  void _goToDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final key = DateFormat('yyyyMMdd').format(d);
    // updates URL + keeps shell nav correct
    context.go('/day/$key');
    setState(() => selectedDay = d);
  }

  @override
  void didUpdateWidget(covariant DayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final incoming = widget.initialDay;
    if (incoming == null) return;

    final normalized = DateTime(incoming.year, incoming.month, incoming.day);
    if (!isSameDay(normalized, selectedDay)) {
      setState(() => selectedDay = normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskControllerProvider);

    final nowAsync = ref.watch(nowProvider);
    final now = nowAsync.value ?? DateTime.now();
    final day = selectedDay;
    // Date in appbar formatted as "Friday, 16 Jan"
    final dateLabel = DateFormat('EEEE, d MMM').format(day);

    const gridLineOffset = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel),
            SizedBox(width: 6),
            Text(now.year.toString(), style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () => showAddTaskSheet(context, ref, day),
          child: const Icon(Icons.add),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final dayTasks = tasks
                      .where((t) => isSameDay(now, day))
                      .toList();

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: (details) {
                      final vx = details.velocity.pixelsPerSecond.dx;

                      // tune this threshold if needed
                      const threshold = 300.0;

                      if (vx.abs() < threshold) return;

                      if (vx < 0) {
                        // swipe left -> next day
                        _goToDay(day.add(const Duration(days: 1)));
                      } else {
                        // swipe right -> previous day
                        _goToDay(day.subtract(const Duration(days: 1)));
                      }
                    },
                    child: Timeline(
                      day: day,
                      now: now,
                      hourHeight: _hourHeight,
                      gridLineOffset: gridLineOffset,
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
                          showEditTaskSheet(context, ref, day, task),
                      onResizeCommit: (updatedTask) async {
                        await ref
                            .read(taskControllerProvider.notifier)
                            .upsert(updatedTask);
                      },
                    ),
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
}
