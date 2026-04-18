import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_ship.dart';

class BossShip extends EnemyShip {
  final double minX;
  final double maxX;
  final double targetY;
  final double horizontalSpeed;

  int direction = 1;

  late SpriteComponent bossVisual;
  bool isSecondPhaseVisualActive = false;

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
          useDamageColorEffect: false,
          color: const Color(0x00FFFFFF),
        ) {
    size = Vector2(170, 170);
    paint.color = Colors.transparent;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final normalSprite = await Sprite.load('boss.png');

    bossVisual = SpriteComponent(
      sprite: normalSprite,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );

    add(bossVisual);
  }

  @override
  bool takeHit() {
    final bool isDestroyed = super.takeHit();

    if (!isDestroyed && health <= 5 && !isSecondPhaseVisualActive) {
      _switchToSecondPhaseVisual();
    }

    return isDestroyed;
  }

  Future<void> _switchToSecondPhaseVisual() async {
    isSecondPhaseVisualActive = true;
    bossVisual.sprite = await Sprite.load('bosstwo.png');
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