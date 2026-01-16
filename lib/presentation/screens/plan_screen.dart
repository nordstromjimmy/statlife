import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/tasks/task_controller.dart';
import '../widgets/calendar/month_view.dart';
import '../widgets/calendar/week_view.dart';

enum PlanView { week, month }

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  PlanView view = PlanView.week;
  DateTime anchor = DateTime.now(); // week/month centered around this

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskControllerProvider);

    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        actions: [
          SegmentedButton<PlanView>(
            segments: const [
              ButtonSegment(value: PlanView.week, label: Text('Week')),
              ButtonSegment(value: PlanView.month, label: Text('Month')),
            ],
            selected: {view},
            onSelectionChanged: (s) => setState(() => view = s.first),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: view == PlanView.week
                ? WeekView(
                    anchor: anchorDay,
                    tasks: tasks,
                    onPickDay: (day) => _openDay(context, day),
                    onPrev: () => setState(
                      () => anchor = anchor.subtract(const Duration(days: 7)),
                    ),
                    onNext: () => setState(
                      () => anchor = anchor.add(const Duration(days: 7)),
                    ),
                  )
                : MonthView(
                    anchor: anchorDay,
                    tasks: tasks,
                    onPickDay: (day) => _openDay(context, day),
                    onPrev: () => setState(
                      () => anchor = DateTime(anchor.year, anchor.month - 1, 1),
                    ),
                    onNext: () => setState(
                      () => anchor = DateTime(anchor.year, anchor.month + 1, 1),
                    ),
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Tasks error: $e')),
      ),
    );
  }

  void _openDay(BuildContext context, DateTime day) {
    final key = DateFormat('yyyyMMdd').format(day);
    context.go('/day/$key'); // jumps to the Day tab route but stays in shell
  }
}
