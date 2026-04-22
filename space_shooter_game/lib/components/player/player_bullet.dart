import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerBullet extends RectangleComponent {
  final double speed;
  final double horizontalSpeed;

  PlayerBullet({
    required Vector2 position,
    this.speed = 400,
    this.horizontalSpeed = 0,
    Vector2? bulletSize,
    Color? bulletColor,
  }) : super(
          position: position,
          size: bulletSize ?? Vector2(6, 18),
          anchor: Anchor.center,
          paint: Paint()
            ..color = bulletColor ?? const Color(0xFFFFFF66),
        );

  @override
  void update(double dt) {
    super.update(dt);

    position.y -= speed * dt;
    position.x += horizontalSpeed * dt;

    final bool isOutOfTop = position.y + (size.y / 2) < 0;
    final bool isOutOfLeft = position.x + (size.x / 2) < 0;
    final bool isOutOfRight = position.x - (size.x / 2) > 2000;

    if (isOutOfTop || isOutOfLeft || isOutOfRight) {
      removeFromParent();
    }
  }
}