import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyShip extends RectangleComponent {
  final double speed;
  final int maxHealth;
  final int scoreValue;
  final Color baseColor;

  int health;

  EnemyShip({
    required Vector2 position,
    this.speed = 120,
    this.maxHealth = 1,
    this.scoreValue = 1,
    Color color = const Color(0xFFFF6B6B),
  }) : baseColor = color,
       health = maxHealth,
       super(
         position: position,
         size: Vector2(52, 24),
         anchor: Anchor.center,
         paint: Paint()..color = color,
       );

  bool takeHit() {
    health--;

    if (health <= 0) {
      return true;
    }

    _updateDamageColor();
    return false;
  }

  void _updateDamageColor() {
    final double damageProgress = 1 - (health / maxHealth);

    paint.color = Color.lerp(
      baseColor,
      const Color(0xFFFFF176),
      damageProgress * 0.8,
    )!;
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