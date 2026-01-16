import 'package:flutter/material.dart';

DateTime roundToStep(DateTime dt, int stepMinutes) {
  final total = dt.hour * 60 + dt.minute;
  final snapped = (total / stepMinutes).round() * stepMinutes;

  var h = snapped ~/ 60;
  var m = snapped % 60;

  // handle 24:00 edge case
  if (h >= 24) {
    h = 23;
    m = 59;
  }

  return DateTime(dt.year, dt.month, dt.day, h, m);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Future<TimeOfDay?> pickTime(BuildContext context, DateTime initial) {
  return showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
  );
}
