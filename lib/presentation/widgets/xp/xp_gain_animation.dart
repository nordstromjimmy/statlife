import 'package:flutter/material.dart';

class XpGainAnimation extends StatefulWidget {
  const XpGainAnimation({
    super.key,
    required this.xpAmount,
    required this.position,
    required this.onComplete,
  });

  final int xpAmount;
  final Offset position;
  final VoidCallback onComplete;

  @override
  State<XpGainAnimation> createState() => _XpGainAnimationState();
}

class _XpGainAnimationState extends State<XpGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _offsetAnimation = Tween<double>(
      begin: 0.0,
      end: -80.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 40,
          top: widget.position.dy + _offsetAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.xpAmount} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper to show XP gain overlay
class XpGainOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required int xpAmount,
    required Offset position,
  }) {
    // Remove previous if exists
    _currentEntry?.remove();

    _currentEntry = OverlayEntry(
      builder: (context) => XpGainAnimation(
        xpAmount: xpAmount,
        position: position,
        onComplete: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }
}
