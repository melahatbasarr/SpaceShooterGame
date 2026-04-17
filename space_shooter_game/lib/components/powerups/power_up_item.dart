import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum PowerUpType {
  rapidFire,
  shield,
}

class PowerUpItem extends RectangleComponent {
  final double speed;
  final PowerUpType type;

  PowerUpItem({
    required Vector2 position,
    required this.type,
    this.speed = 110,
  }) : super(
          position: position,
          size: Vector2(24, 24),
          anchor: Anchor.center,
          paint: Paint()..color = _getColor(type),
        );

  static Color _getColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.rapidFire:
        return const Color(0xFFFFD54F);
      case PowerUpType.shield:
        return const Color(0xFF64B5F6);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y - (size.y / 2) > 900) {
      removeFromParent();
    }
  }
}