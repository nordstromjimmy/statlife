import 'package:flutter/material.dart';
import '../../../domain/logic/leveling.dart';
import '../../../domain/models/profile.dart';
import 'animated_level_badge.dart';
import 'xp_bar.dart';

class XpDisplay extends StatefulWidget {
  const XpDisplay({
    super.key,
    required this.profile,
    required this.levelBadgeKey,
  });

  final Profile profile;
  final GlobalKey<AnimatedLevelBadgeState> levelBadgeKey;

  @override
  State<XpDisplay> createState() => _XpDisplayState();
}

class _XpDisplayState extends State<XpDisplay> {
  int _previousTotalXp = 0;
  int _previousLevel = 0;
  final _xpBarKey = GlobalKey<XpBarState>(); // Add key for XpBar

  @override
  void initState() {
    super.initState();
    _previousTotalXp = widget.profile.totalXp;
    final levelInfo = computeLevelFromTotalXp(widget.profile.totalXp);
    _previousLevel = levelInfo.level;
  }

  @override
  void didUpdateWidget(XpDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newTotalXp = widget.profile.totalXp;
    final newLevelInfo = computeLevelFromTotalXp(newTotalXp);

    // Check for level up
    if (newLevelInfo.level > _previousLevel) {
      // Calculate the new progress for the XpBar
      final newProgress = newLevelInfo.xpIntoLevel / newLevelInfo.xpForNext;

      widget.levelBadgeKey.currentState?.triggerLevelUp();

      // Trigger XpBar level up animation with the new progress
      _xpBarKey.currentState?.triggerManualLevelUp(newProgress: newProgress);
    }

    _previousTotalXp = newTotalXp;
    _previousLevel = newLevelInfo.level;
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = computeLevelFromTotalXp(widget.profile.totalXp);
    final totalXpForNextLevel =
        widget.profile.totalXp - levelInfo.xpIntoLevel + levelInfo.xpForNext;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated Level Badge
          AnimatedLevelBadge(
            key: widget.levelBadgeKey,
            level: levelInfo.level,
            size: 48,
          ),

          const SizedBox(width: 12),

          // XP Bar with labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${levelInfo.level}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${widget.profile.totalXp} / $totalXpForNextLevel XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                XpBar(
                  key: _xpBarKey, // Add the key
                  currentXp: levelInfo.xpIntoLevel,
                  requiredXp: levelInfo.xpForNext,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
