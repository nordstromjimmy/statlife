// lib/presentation/widgets/animated_level_badge.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLevelBadge extends StatefulWidget {
  const AnimatedLevelBadge({super.key, required this.level, this.size = 48.0});

  final int level;
  final double size;

  @override
  State<AnimatedLevelBadge> createState() => AnimatedLevelBadgeState();
}

class AnimatedLevelBadgeState extends State<AnimatedLevelBadge>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  int _previousLevel = 0;
  bool _isLevelingUp = false;

  @override
  void initState() {
    super.initState();
    _previousLevel = widget.level;

    // Pulse animation for level up
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation for particle ring
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Particle explosion
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_pulseController);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedLevelBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.level > _previousLevel) {
      _triggerLevelUpAnimation();
      _previousLevel = widget.level;
    }
  }

  void _triggerLevelUpAnimation() {
    setState(() => _isLevelingUp = true);

    _pulseController.forward(from: 0.0);
    _rotationController.forward(from: 0.0);
    _particleController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLevelingUp = false);
      }
    });
  }

  // Public method to trigger animation externally
  void triggerLevelUp() {
    _triggerLevelUpAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _rotationController,
        _particleController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 1.5,
          height: widget.size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Particle ring
              if (_isLevelingUp)
                CustomPaint(
                  painter: _LevelUpParticlePainter(
                    progress: _particleController.value,
                    rotation: _rotationController.value * 2 * math.pi,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  size: Size(widget.size * 1.5, widget.size * 1.5),
                ),

              // Main badge
              Transform.scale(
                scale: _isLevelingUp ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.tertiary,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(
                          alpha: _isLevelingUp ? _glowAnimation.value : 0.3,
                        ),
                        blurRadius: _isLevelingUp ? 20 : 8,
                        spreadRadius: _isLevelingUp ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.level}',
                      style: TextStyle(
                        fontSize: widget.size * 0.4,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF020617),
                      ),
                    ),
                  ),
                ),
              ),

              // Outer glow ring on level up
              if (_isLevelingUp)
                Transform.scale(
                  scale: 1.0 + (_particleController.value * 0.3),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(
                          alpha: 1.0 - _particleController.value,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LevelUpParticlePainter extends CustomPainter {
  final double progress;
  final double rotation;
  final Color color;

  _LevelUpParticlePainter({
    required this.progress,
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 3;
    final particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi + rotation;
      final distance = baseRadius + (progress * baseRadius * 0.5);

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final particleSize = 3.0 * (1.0 - progress);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_LevelUpParticlePainter oldDelegate) => true;
}
