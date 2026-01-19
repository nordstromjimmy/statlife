import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/auth/auth_controller.dart';
import '../../application/profile/profile_controller.dart';
import '../../application/tasks/task_controller.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/task.dart';
import '../sheets/add_task_sheet.dart';
import '../sheets/edit_task_sheet.dart';
import '../widgets/timeline/day_timeline.dart';
import 'package:go_router/go_router.dart';
import '../widgets/xp/animated_level_badge.dart';
import '../widgets/xp/xp_display.dart';
import '../widgets/xp/xp_gain_animation.dart';

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
  static const _hourHeight = 64.0;
  final _levelBadgeKey = GlobalKey<AnimatedLevelBadgeState>();

  @override
  void initState() {
    super.initState();
    final base = widget.initialDay ?? DateTime.now();
    selectedDay = DateTime(base.year, base.month, base.day);
  }

  @override
  void didUpdateWidget(covariant DayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialDay != oldWidget.initialDay) {
      final base = widget.initialDay ?? DateTime.now();
      setState(() {
        selectedDay = DateTime(base.year, base.month, base.day);
      });
    }
  }

  void _goToDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final key = DateFormat('yyyyMMdd').format(d);

    context.go('/day/$key');
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final authAsync = ref.watch(authControllerProvider);

    final nowAsync = ref.watch(nowProvider);
    final now = nowAsync.value ?? DateTime.now();
    final day = selectedDay;
    // Date in appbar formatted as "Friday, 16 Jan"
    final dateLabel = DateFormat('EEEE, d MMM').format(day);

    final profile = profileAsync.valueOrNull;
    final auth = authAsync.valueOrNull;
    final welcomeName = (auth?.isGuest ?? true)
        ? 'Guest'
        : (profile?.name ?? 'User');

    const gridLineOffset = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    welcomeName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dateLabel),
                const SizedBox(height: 2),
                Text(now.year.toString(), style: const TextStyle(fontSize: 16)),
              ],
            ),
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

      body: Column(
        children: [
          // XP Bar Section (NEW)
          profileAsync.when(
            data: (profile) {
              return XpDisplay(profile: profile, levelBadgeKey: _levelBadgeKey);
            },
            loading: () => const SizedBox(height: 72),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final dayTasks = tasks
                    .where((t) => isSameDay(t.day, day))
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

                      // Award XP and show animation
                      if (checked && !task.isCompleted) {
                        // Show floating +XP animation
                        final renderBox =
                            context.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          final position = renderBox.localToGlobal(
                            Offset(
                              renderBox.size.width / 2,
                              renderBox.size.height / 3,
                            ),
                          );

                          XpGainOverlay.show(
                            context,
                            xpAmount: task.xp,
                            position: position,
                          );
                        }

                        // Add XP to profile (this triggers the XP bar animation)
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
    );
  }
}
