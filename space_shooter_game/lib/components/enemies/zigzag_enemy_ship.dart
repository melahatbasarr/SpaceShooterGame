import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'enemy_ship.dart';

class ZigzagEnemyShip extends EnemyShip {
  final double minX;
  final double maxX;
  final double horizontalSpeed;

  int direction = 1;

  ZigzagEnemyShip({
    required Vector2 position,
    required this.minX,
    required this.maxX,
    double speed = 120,
    this.horizontalSpeed = 90,
  }) : super(
         position: position,
         speed: speed,
         maxHealth: 1,
         scoreValue: 2,
         color: const Color(0xFFFFA726),
         assetName: 'enemies_two.png',
       );

  @override
  void update(double dt) {
    super.update(dt);

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