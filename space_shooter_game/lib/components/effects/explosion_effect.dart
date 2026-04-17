import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ExplosionEffect extends CircleComponent {
  final double duration;
  final double startRadius;
  final double endRadius;

  double timer = 0;

  ExplosionEffect({
    required Vector2 position,
    this.duration = 0.25,
    this.startRadius = 6,
    this.endRadius = 18,
  }) : super(
          position: position,
          radius: startRadius,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFFB74D),
        );

  @override
  void update(double dt) {
    super.update(dt);

    timer += dt;

    final double progress = (timer / duration).clamp(0.0, 1.0);

    radius = startRadius + ((endRadius - startRadius) * progress);

    final Color color = Color.lerp(
      const Color(0xFFFFF176),
      const Color(0xFFFF7043),
      progress,
    )!;

    paint.color = color.withOpacity(1 - progress);

    if (progress >= 1) {
      removeFromParent();
    }
  }
}