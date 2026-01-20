import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal.dart';
import 'goal_form_sheet.dart';

/// Shows a bottom sheet for editing an existing goal
Future<void> showEditGoalSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Goal goal,
}) async {
  await showGoalFormSheet(context: context, ref: ref, existingGoal: goal);
}
