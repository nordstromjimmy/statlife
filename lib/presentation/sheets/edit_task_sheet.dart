import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task.dart';
import 'task_form_sheet.dart';

/// Shows a bottom sheet for editing an existing task
Future<void> showEditTaskSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime day,
  Task task,
) async {
  await showTaskFormSheet(context, ref, day, existingTask: task);
}
