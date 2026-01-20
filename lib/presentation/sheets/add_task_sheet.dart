import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_form_sheet.dart';

/// Shows a bottom sheet for adding a new task
Future<void> showAddTaskSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime day,
) async {
  await showTaskFormSheet(context, ref, day);
}
