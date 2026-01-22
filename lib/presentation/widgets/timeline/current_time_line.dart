import 'package:flutter/material.dart';

class CurrentTimeLine extends StatelessWidget {
  const CurrentTimeLine({
    super.key,
    required this.now,
    required this.hourHeight,
    required this.gridLineOffset,
  });

  final DateTime now;
  final double hourHeight;
  final double gridLineOffset;

  @override
  Widget build(BuildContext context) {
    final minutes = now.hour * 60 + now.minute;
    var y = (minutes / 60.0) * hourHeight + gridLineOffset;

    // Clamp so it doesn't render outside the timeline
    y = y.clamp(0.0, 24 * hourHeight);
    final dotColor = Color.fromARGB(255, 255, 255, 255);
    final lineColor = Color(0xFFff6532);

    return Positioned(
      left: 0,
      right: 0,
      top: y,
      child: IgnorePointer(
        child: Row(
          children: [
            const SizedBox(width: 60), // align with hour label column
            // dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            // line
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
