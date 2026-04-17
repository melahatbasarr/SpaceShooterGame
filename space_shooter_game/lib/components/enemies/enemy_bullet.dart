import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyBullet extends RectangleComponent {
  final double speed;

  EnemyBullet({
    required Vector2 position,
    this.speed = 240,
  }) : super(
          position: position,
          size: Vector2(8, 20),
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFFC107),
        );

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y - (size.y / 2) > 1200) {
      removeFromParent();
    }
  }
}