import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/goals/goal_controller.dart';
import '../../application/tasks/task_controller.dart';
import '../sheets/add_goal_sheet.dart';
import '../sheets/edit_goal_sheet.dart';
import '../widgets/calendar/month_view.dart';
import '../widgets/calendar/week_view.dart';

enum PlanView { week, month }

enum PlanPage { overview, goals }

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  PlanView view = PlanView.week;
  DateTime anchor = DateTime.now(); // week/month centered around this

  late final PageController _pageController;
  int _pageIndex = 0; // 0 = Overview, 1 = Goals

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskControllerProvider);
    final goalsAsync = ref.watch(goalControllerProvider);

    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  _pageIndex == 0 ? 'Overview' : 'Goals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),

                // Right side controls depend on page
                if (_pageIndex == 0)
                  SegmentedButton<PlanView>(
                    segments: const [
                      ButtonSegment(value: PlanView.week, label: Text('Week')),
                      ButtonSegment(
                        value: PlanView.month,
                        label: Text('Month'),
                      ),
                    ],
                    selected: {view},
                    onSelectionChanged: (s) => setState(() => view = s.first),
                  )
                else
                  FilledButton.icon(
                    onPressed: () =>
                        showAddGoalSheet(context: context, ref: ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
              ],
            ),
          ),

          // Swipe area
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: [
                // PAGE 0: Overview (your existing week/month view)
                tasksAsync.when(
                  data: (tasks) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: view == PlanView.week
                          ? WeekView(
                              anchor: anchorDay,
                              tasks: tasks,
                              onPickDay: (day) => _openDay(context, day),
                              onPrev: () => setState(
                                () => anchor = anchor.subtract(
                                  const Duration(days: 7),
                                ),
                              ),
                              onNext: () => setState(
                                () => anchor = anchor.add(
                                  const Duration(days: 7),
                                ),
                              ),
                            )
                          : MonthView(
                              anchor: anchorDay,
                              tasks: tasks,
                              onPickDay: (day) => _openDay(context, day),
                              onPrev: () => setState(
                                () => anchor = DateTime(
                                  anchor.year,
                                  anchor.month - 1,
                                  1,
                                ),
                              ),
                              onNext: () => setState(
                                () => anchor = DateTime(
                                  anchor.year,
                                  anchor.month + 1,
                                  1,
                                ),
                              ),
                            ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Tasks error: $e')),
                ),

                // PAGE 1: Goals (list)
                goalsAsync.when(
                  data: (goals) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: goals.isEmpty
                          ? Center(
                              child: Text(
                                'No goals yet.\nAdd something you wish to start doing more regularly.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            )
                          : ListView.separated(
                              itemCount: goals.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final g = goals[i];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => showEditGoalSheet(
                                    context: context,
                                    ref: ref,
                                    goal: g,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.06,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                g.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleSmall,
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Goals error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDay(BuildContext context, DateTime day) {
    final key = DateFormat('yyyyMMdd').format(day);
    context.go('/day/$key'); // jumps to the Day tab route but stays in shell
  }
}
