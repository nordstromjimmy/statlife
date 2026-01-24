import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth/auth_controller.dart';
import '../../application/migration/data_migration_service.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'Join Evolvem',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to sync your progress across devices',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),

                    const SizedBox(height: 32),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                final email = _emailController.text.trim();
                                final password = _passwordController.text;

                                try {
                                  // 1. Check for guest data
                                  final migrationService = ref.read(
                                    dataMigrationServiceProvider,
                                  );
                                  final hasGuestData = await migrationService
                                      .hasGuestData();

                                  bool shouldMigrate = false;
                                  GuestDataSummary? summary;

                                  if (hasGuestData) {
                                    summary = await migrationService
                                        .getGuestDataSummary();
                                    shouldMigrate = await _showMigrationDialog(
                                      context,
                                      taskCount: summary.taskCount,
                                      goalCount: summary.goalCount,
                                      xp: summary.xp,
                                    );
                                  }

                                  // Show loading if migrating
                                  if (shouldMigrate) {
                                    setState(() => _isLoading = true);
                                  }

                                  // 2. Sign up WITHOUT updating auth state yet
                                  final userId = await ref
                                      .read(authControllerProvider.notifier)
                                      .signUpWithoutStateUpdate(
                                        email: email,
                                        password: password,
                                      );

                                  if (userId == null) {
                                    throw Exception(
                                      'Signup failed - no user ID returned',
                                    );
                                  }

                                  // 3. Migrate data BEFORE updating auth state
                                  if (shouldMigrate) {
                                    final success = await migrationService
                                        .migrateGuestDataToUser(userId);

                                    // Hide loading
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }

                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Transferred ${summary!.taskCount} tasks and ${summary.xp} XP!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else if (!shouldMigrate && hasGuestData) {
                                    await migrationService.clearGuestData();
                                  }

                                  // 4. NOW update auth state (this triggers controller rebuilds)
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .updateAuthState(
                                        userId: userId,
                                        email: email,
                                      );

                                  // 5. Navigate
                                  if (context.mounted) {
                                    context.go('/');
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sign up failed: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign In Link
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/signin'),
                        child: Text(
                          'Already have an account? Sign in',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated icon
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                Icons.cloud_upload,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Progress indicator
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Text
                        Text(
                          'Transferring your data',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Syncing tasks, goals, and progress...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<bool> _showMigrationDialog(
  BuildContext context, {
  required int taskCount,
  required int goalCount,
  required int xp,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Must make a choice
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.upload, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Keep Your Progress?')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We found data from your guest session:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildDataItem(context, Icons.task_alt, '$taskCount tasks'),
          const SizedBox(height: 8),
          _buildDataItem(context, Icons.flag, '$goalCount goals'),
          const SizedBox(height: 8),
          _buildDataItem(context, Icons.star, '$xp XP'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Transfer this data to your new account?',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Start Fresh'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Keep Data'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return result ?? false;
}

Widget _buildDataItem(BuildContext context, IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(fontSize: 15)),
    ],
  );
}
