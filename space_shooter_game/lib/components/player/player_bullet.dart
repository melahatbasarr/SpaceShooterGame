import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerBullet extends RectangleComponent {
  final double speed;

  PlayerBullet({
    required Vector2 position,
    this.speed = 400,
  }) : super(
          position: position,
          size: Vector2(6, 18),
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFFFF66),
        );

  @override
  void update(double dt) {
    super.update(dt);

    position.y -= speed * dt;

    if (position.y + (size.y / 2) < 0) {
      removeFromParent();
    }
  }
}