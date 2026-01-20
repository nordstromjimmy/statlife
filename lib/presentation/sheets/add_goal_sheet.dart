import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_form_sheet.dart';

/// Shows a bottom sheet for adding a new goal
Future<void> showAddGoalSheet({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  await showGoalFormSheet(context: context, ref: ref);
}
