import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/goals/goal_controller.dart';

Future<void> showAddGoalSheet({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final titleController = TextEditingController();
  var minutes = 30;

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
                  decoration: const InputDecoration(
                    labelText: 'Goal title',
                    hintText: 'e.g. Read this book',
                  ),
                ),
                const SizedBox(height: 12),

                // Default duration
                Row(
                  children: [
                    Text(
                      'Default duration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: minutes > 5
                          ? () => setState(
                              () => minutes = (minutes - 5).clamp(5, 600),
                            )
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$minutes min',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => minutes = (minutes + 5).clamp(5, 600)),
                      icon: const Icon(Icons.add),
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

                          await ref
                              .read(goalControllerProvider.notifier)
                              .create(
                                title: title,
                                defaultDurationMinutes: minutes,
                              );

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Add goal'),
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
