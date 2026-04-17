import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_ship.dart';

class BossShip extends EnemyShip {
  final double minX;
  final double maxX;
  final double targetY;
  final double horizontalSpeed;

  int direction = 1;

  BossShip({
    required Vector2 position,
    required this.minX,
    required this.maxX,
    this.targetY = 110,
    this.horizontalSpeed = 120,
    double speed = 80,
  }) : super(
          position: position,
          speed: speed,
          maxHealth: 20,
          scoreValue: 20,
          color: const Color(0xFFEF5350),
        ) {
    size = Vector2(150, 60);
  }

  @override
  void update(double dt) {
    if (position.y < targetY) {
      position.y += speed * dt;

      if (position.y > targetY) {
        position.y = targetY;
      }

      return;
    }

    position.x += direction * horizontalSpeed * dt;

    final double halfWidth = size.x / 2;

    if (position.x <= minX + halfWidth) {
      position.x = minX + halfWidth;
      direction = 1;
    } else if (position.x >= maxX - halfWidth) {
      position.x = maxX - halfWidth;
      direction = -1;
    }
  }
}