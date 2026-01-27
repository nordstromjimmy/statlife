import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/achievement/achievement_controller.dart';
import '../../application/auth/auth_controller.dart';
import '../../application/goals/goal_controller.dart';
import '../../application/profile/profile_controller.dart';
import '../../application/providers.dart';
import '../../application/tasks/task_controller.dart';
import '../../domain/logic/leveling.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/task.dart';
import '../widgets/xp/xp_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  bool _isGuest(AuthState? auth) => auth == null || auth.isGuest;
  bool _isAuthenticated(AuthState? auth) => auth?.isAuthenticated ?? false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final tasksAsync = ref.watch(taskControllerProvider);
    final authAsync = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: profileAsync.when(
        data: (profile) {
          final levelInfo = computeLevelFromTotalXp(profile.totalXp);
          final tasks = tasksAsync.value ?? [];
          final auth = authAsync.value;

          final completedTasks = tasks.where((t) => t.isCompleted).length;
          final totalTasks = tasks.length;
          final completionRate = totalTasks > 0
              ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
              : '0.0';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guest CTA Banner
                if (_isGuest(auth)) _buildGuestBanner(context),
                if (_isGuest(auth)) const SizedBox(height: 24),

                // Name Section (for authenticated users)
                if (_isAuthenticated(auth))
                  _buildNameSection(context, ref, profile),
                if (_isAuthenticated(auth)) const SizedBox(height: 24),

                // Level Card
                _buildLevelCard(context, profile, levelInfo),

                const SizedBox(height: 24),

                _buildAchievementsCard(context, ref, auth),

                const SizedBox(height: 24),

                // Stats Grid
                _buildStatsGrid(
                  context,
                  totalTasks: totalTasks,
                  completedTasks: completedTasks,
                  completionRate: completionRate,
                  totalXp: profile.totalXp,
                ),

                const SizedBox(height: 24),

                // Additional Info Section
                _buildInfoSection(context, ref, profile, auth),

                const SizedBox(height: 24),

                // Sign Out Button (only show if authenticated)
                if (_isAuthenticated(auth))
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final shouldSignOut = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out? Your data will remain synced in the cloud.',
                            ),
                            actions: [
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  Spacer(),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Sign Out'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                        if (shouldSignOut == true && context.mounted) {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.5),
                        ),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }

  Widget _buildGuestBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock Full Potential',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to save your progress and never lose your data',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push('/signup'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/signin'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(BuildContext context, WidgetRef ref, profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              profile.name ?? 'Set your name',
              maxLines: 2,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: profile.name != null ? null : Colors.white38,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showEditNameDialog(context, ref, profile),
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    profile,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _EditNameDialog(
        initialName: profile.name ?? '',
        onSave: (name) {
          ref.read(profileControllerProvider.notifier).updateName(name);
        },
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, profile, levelInfo) {
    final progress = levelInfo.xpIntoLevel / levelInfo.xpForNext;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Level Badge
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LEVEL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${profile.level}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // XP Progress
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP Progress',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    '${profile.totalXp} / ${profile.totalXp - levelInfo.xpIntoLevel + levelInfo.xpForNext}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, // Force full width
                child: XpBar(
                  currentXp: levelInfo.xpIntoLevel,
                  requiredXp: levelInfo.xpForNext,
                  height: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% to Level ${profile.level + 1}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalTasks,
    required int completedTasks,
    required String completionRate,
    required int totalXp,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.task_alt,
                label: 'Completed',
                value: '$completedTasks',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.list_alt,
                label: 'Total Tasks',
                value: '$totalTasks',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.percent,
                label: 'Completion',
                value: '$completionRate%',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.star,
                label: 'Total XP',
                value: '$totalXp',
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // Add this method to your ProfileScreen class:

  Widget _buildAchievementsCard(
    BuildContext context,
    WidgetRef ref,
    AuthState? auth,
  ) {
    // Watch achievements
    final achievementsAsync = ref.watch(achievementControllerProvider);

    return achievementsAsync.when(
      data: (achievements) {
        final unlocked = achievements.where((a) => a.isUnlocked).length;
        final total = achievements.length;
        final progress = unlocked / total;

        return InkWell(
          onTap: _isAuthenticated(auth)
              ? () => context.push('/achievements')
              : () => _showSignUpPrompt(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (_isGuest(auth))
                            Text(
                              'Sign up to unlock',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white60),
                            )
                          else
                            Text(
                              '$unlocked of $total unlocked',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      _isGuest(auth) ? Icons.lock : Icons.chevron_right,
                      color: Colors.white60,
                    ),
                  ],
                ),

                if (_isAuthenticated(auth)) ...[
                  const SizedBox(height: 16),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Recent Unlocks Preview
                  if (unlocked > 0) ...[
                    Text(
                      'Recent unlocks:',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: achievements
                          .where((a) => a.isUnlocked)
                          .take(3)
                          .map((achievement) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Tooltip(
                                message: achievement.title,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      achievement.tierColor,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    achievement.iconPath,
                                    width: 24,
                                    height: 24,
                                    color: Color(achievement.tierColor),
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.emoji_events,
                                      size: 24,
                                      color: Color(achievement.tierColor),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ] else
                    Text(
                      'Complete tasks to unlock achievements!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  // Helper method for sign-up prompt
  void _showSignUpPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up to Unlock'),
        content: const Text(
          'Create an account to track your achievements and unlock rewards as you complete tasks!',
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
              Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/signup');
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref, profile, auth) {
    final createdDate = profile.createdAt;
    final daysSince = DateTime.now().difference(createdDate).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Info',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          context,
          icon: Icons.calendar_today,
          label: 'Member since',
          value: '${createdDate.day}/${createdDate.month}/${createdDate.year}',
        ),
        const SizedBox(height: 8),
        _buildInfoTile(
          context,
          icon: Icons.timer,
          label: 'Days active',
          value: '$daysSince ${daysSince == 1 ? 'day' : 'days'}',
        ),

        // Delete/Clear Data button (for both guest and authenticated)
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteAllDataDialog(context, ref, auth),
            icon: const Icon(Icons.delete_sweep),
            label: Text(_isGuest(auth) ? 'Clear All Data' : 'Reset progress'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
              foregroundColor: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteAllDataDialog(
    BuildContext context,
    WidgetRef ref,
    AuthState? auth,
  ) async {
    final isGuest = _isGuest(auth);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: Text(
          isGuest
              ? 'This will permanently delete all your tasks, goals, and progress. This action cannot be undone.\n\n'
                    '💡 Tip: Create an account to save your progress in the cloud! '
                    'When you sign up, you\'ll be able to transfer this data to your new account.'
              : 'This will permanently delete:\n'
                    '• All tasks\n'
                    '• All goals\n'
                    '• All achievement progress\n'
                    '• XP and level\n\n'
                    'Your account will remain active but all data will be cleared.\n\n'
                    'This action cannot be undone.',
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete All'),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      if (isGuest) {
        await _clearAllLocalData(ref);
      } else {
        await _deleteAllUserData(ref);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _clearAllLocalData(WidgetRef ref) async {
    // Clear tasks
    final taskController = ref.read(taskControllerProvider.notifier);
    final tasks = ref.read(taskControllerProvider).value ?? [];
    for (final task in tasks) {
      await taskController.delete(task.id);
    }

    // Clear goals
    final goalController = ref.read(goalControllerProvider.notifier);
    final goals = ref.read(goalControllerProvider).value ?? [];
    for (final goal in goals) {
      await goalController.delete(goal.id);
    }

    // Clear profile - use the repository directly
    final localStore = ref.read(localStoreProvider);

    // Clear the guest profile from local storage
    await localStore.remove('profile'); // Remove guest_profile key

    // Force the profile controller to rebuild with a fresh profile
    ref.invalidate(profileControllerProvider);
  }

  Future<void> _deleteAllUserData(WidgetRef ref) async {
    // 1. Delete all tasks
    final taskController = ref.read(taskControllerProvider.notifier);
    final tasks = ref.read(taskControllerProvider).value ?? [];
    for (final task in tasks) {
      await taskController.delete(task.id);
    }

    // 2. Delete all goals
    final goalController = ref.read(goalControllerProvider.notifier);
    final goals = ref.read(goalControllerProvider).value ?? [];
    for (final goal in goals) {
      await goalController.delete(goal.id);
    }

    // 3. Reset profile (level 1, 0 XP, keep name)
    final profileController = ref.read(profileControllerProvider.notifier);
    await profileController.resetProgress();

    // 4. Clear achievements (both local AND Supabase)
    final supabaseAchievementDatasource = ref.read(
      supabaseAchievementDatasourceProvider,
    );
    await supabaseAchievementDatasource
        .deleteAllAchievements(); // Delete from Supabase

    final achievementRepo = ref.read(achievementRepositoryProvider);
    await achievementRepo.clear(); // Clear local cache

    // 5. Force all controllers to rebuild
    ref.invalidate(taskControllerProvider);
    ref.invalidate(goalControllerProvider);
    ref.invalidate(profileControllerProvider);
    ref.invalidate(achievementControllerProvider);
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName, required this.onSave});

  final String initialName;
  final void Function(String name) onSave;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Your name',
          hintText: 'e.g. Alex',
        ),
        textCapitalization: TextCapitalization.words,
        autofocus: true,
      ),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Spacer(),
            FilledButton(
              onPressed: () {
                widget.onSave(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
