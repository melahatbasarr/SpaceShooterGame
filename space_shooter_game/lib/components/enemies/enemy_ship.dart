import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyShip extends RectangleComponent {
  final double speed;
  final int maxHealth;
  final int scoreValue;
  final Color baseColor;
  final bool useDamageColorEffect;
  final String? assetName;

  int health;

  PositionComponent? enemyVisual;

  EnemyShip({
    required Vector2 position,
    this.speed = 120,
    this.maxHealth = 1,
    this.scoreValue = 1,
    this.useDamageColorEffect = true,
    this.assetName = 'enemies_one.png',
    Color color = const Color(0xFFFF6B6B),
  }) : baseColor = color,
       health = maxHealth,
       super(
         position: position,
         size: Vector2(52, 24),
         anchor: Anchor.center,
         paint: Paint()..color = Colors.transparent,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _createEnemyVisual();
  }

  Future<void> _createEnemyVisual() async {
    if (assetName == null || assetName!.isEmpty) {
      enemyVisual = RectangleComponent(
        size: _getVisualSize(),
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = baseColor,
      );

      await add(enemyVisual!);
      return;
    }

    try {
      final sprite = await Sprite.load(assetName!);

      enemyVisual = SpriteComponent(
        sprite: sprite,
        size: _getVisualSize(),
        anchor: Anchor.center,
        position: size / 2,
      );

      await add(enemyVisual!);
    } catch (_) {
      enemyVisual = RectangleComponent(
        size: _getVisualSize(),
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = baseColor,
      );

      await add(enemyVisual!);
    }
  }

  Vector2 _getVisualSize() {
    return Vector2(64, 64);
  }

  bool takeHit({int damage = 1}) {
    if (damage <= 0) {
      return false;
    }

    health -= damage;

    if (health < 0) {
      health = 0;
    }

    if (health <= 0) {
      return true;
    }

    if (useDamageColorEffect) {
      _updateDamageColor();
    }

    return false;
  }

  void _updateDamageColor() {
    final double damageProgress = 1 - (health / maxHealth);

    final Color damagedColor = Color.lerp(
      baseColor,
      const Color(0xFFFFF176),
      damageProgress * 0.8,
    )!;

    if (enemyVisual is RectangleComponent) {
      (enemyVisual as RectangleComponent).paint.color = damagedColor;
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