import 'package:flutter/material.dart';
import 'dart:math' as math;

class XpBar extends StatefulWidget {
  const XpBar({
    super.key,
    required this.currentXp,
    required this.requiredXp,
    this.height = 8.0,
    this.borderRadius = 8.0,
    this.showLabel = false,
    this.onLevelUp,
  });

  final int currentXp;
  final int requiredXp;
  final double height;
  final double borderRadius;
  final bool showLabel;
  final VoidCallback? onLevelUp;

  @override
  State<XpBar> createState() => XpBarState();
}

class XpBarState extends State<XpBar> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  double _previousProgress = 0.0;
  double _currentVisualProgress = 0.0;
  bool _isLevelingUp = false;

  @override
  void initState() {
    super.initState();

    final initialProgress = _getProgress();
    _previousProgress = initialProgress;
    _currentVisualProgress = initialProgress;

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _progressAnimation =
        Tween<double>(begin: initialProgress, end: initialProgress).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _progressController.value = 1.0;
  }

  @override
  void didUpdateWidget(XpBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newProgress = _getProgress();

    if (_isLevelingUp) {
      return;
    }

    if (newProgress != _previousProgress) {
      if (newProgress < _previousProgress &&
          oldWidget.currentXp < widget.currentXp) {
      } else if (newProgress > _previousProgress) {
        _triggerXpGain(newProgress);
      }

      _previousProgress = newProgress;
    }
  }

  void triggerManualLevelUp({required double newProgress}) {
    if (!mounted) return;
    setState(() => _isLevelingUp = true);

    _progressAnimation = Tween<double>(begin: _currentVisualProgress, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    _progressController.forward(from: 0.0).then((_) {
      _currentVisualProgress = 1.0;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _progressAnimation = Tween<double>(begin: 0.0, end: newProgress)
            .animate(
              CurvedAnimation(
                parent: _progressController,
                curve: Curves.easeOutCubic,
              ),
            );

        _progressController.forward(from: 0.0).then((_) {
          _currentVisualProgress = newProgress;
        });

        setState(() => _isLevelingUp = false);
        _previousProgress = newProgress;
      });
    });
  }

  void _triggerXpGain(double newProgress) {
    _progressAnimation =
        Tween<double>(begin: _currentVisualProgress, end: newProgress).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    _progressController.forward(from: 0.0).then((_) {
      _currentVisualProgress = newProgress;
    });
    _pulseController.forward(from: 0.0);
  }

  double _getProgress() {
    return widget.requiredXp > 0
        ? (widget.currentXp / widget.requiredXp).clamp(0.0, 1.0)
        : 0.0;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.white70),
              ),
              Text(
                '${widget.currentXp} / ${widget.requiredXp}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isLevelingUp
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: _isLevelingUp ? 2 : 1,
            ),
            boxShadow: _isLevelingUp
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _progressAnimation,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scaleY: _pulseAnimation.value,
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLevelingUp
                                  ? [
                                      Theme.of(context).colorScheme.onTertiary,
                                      Theme.of(context).colorScheme.tertiary,
                                    ]
                                  : [
                                      Theme.of(context).colorScheme.onTertiary,
                                      Theme.of(context).colorScheme.tertiary,
                                    ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                                blurRadius: _isLevelingUp ? 12 : 8,
                                spreadRadius: _isLevelingUp ? 2 : 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                if (_progressAnimation.value > 0)
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Transform.translate(
                          offset: Offset(
                            (_shimmerController.value * 2 - 1) * 100,
                            0,
                          ),
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                if (_isLevelingUp)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ParticlePainter(
                          progress: _progressController.value,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        size: Size(double.infinity, widget.height),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final math.Random _random = math.Random(42);

  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.6);

    for (int i = 0; i < 20; i++) {
      final x = _random.nextDouble() * size.width;
      final baseY = size.height / 2;
      final y = baseY + (progress * 20 * (_random.nextDouble() - 0.5));
      final radius = (1 - progress) * 2;

      if (radius > 0) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
