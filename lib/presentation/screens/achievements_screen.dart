import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/achievement/achievement_controller.dart';
import '../../domain/models/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          final unlocked = achievements.where((a) => a.isUnlocked).length;
          final total = achievements.length;

          return Column(
            children: [
              // Progress Summary
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$unlocked / $total',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Achievements Unlocked',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: unlocked / total,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Achievement List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: achievements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _AchievementCard(achievement: achievement);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final isLocked = achievement.isLocked;
    final progress = achievement.progressPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? Colors.white.withValues(alpha: 0.06)
              : Color(achievement.tierColor).withValues(alpha: 0.5),
          width: isLocked ? 1 : 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(
                achievement.tierColor,
              ).withValues(alpha: isLocked ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Badge image
                Opacity(
                  opacity: isLocked ? 0.3 : 1.0,
                  child: Image.asset(
                    achievement.iconPath,
                    width: 40,
                    height: 40,
                    color: isLocked
                        ? Colors.grey
                        : Color(achievement.tierColor),
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: isLocked
                          ? Colors.grey
                          : Color(achievement.tierColor),
                    ),
                  ),
                ),
                // Lock overlay
                if (isLocked)
                  Icon(
                    Icons.lock,
                    size: 24,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.white60 : null,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  achievement.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 8),

                // Progress bar (only show if locked and has progress)
                if (isLocked && achievement.currentProgress > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(achievement.tierColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.currentProgress} / ${achievement.targetProgress}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                // Unlocked date or reward
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(
                          achievement.tierColor,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTierName(achievement.tier),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(achievement.tierColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reward or unlock date
                    if (isLocked)
                      Text(
                        '+${achievement.xpReward} XP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      )
                    else
                      Text(
                        'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Checkmark for unlocked
          if (!isLocked)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  String _getTierName(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.diamond:
        return 'Diamond';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
