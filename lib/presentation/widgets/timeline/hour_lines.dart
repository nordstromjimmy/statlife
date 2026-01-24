import 'package:flutter/material.dart';

class HalfHourLine extends StatelessWidget {
  const HalfHourLine({super.key, required this.top});
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 68,
      right: 0,
      top: top,
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.04),
      ),
    );
  }
}

class HourLine extends StatelessWidget {
  const HourLine({
    super.key,
    required this.hour,
    required this.top,
    required this.lineOffset,
  });
  final int hour;
  final double top;
  final double lineOffset;

  @override
  Widget build(BuildContext context) {
    final label = '${hour.toString().padLeft(2, '0')}:00';

    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: SizedBox(
        height: 22, // enough for text
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 2),
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: lineOffset), // line sits mid-row
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
