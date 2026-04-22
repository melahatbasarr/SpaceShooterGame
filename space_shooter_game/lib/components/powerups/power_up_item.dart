import 'dart:math' as math;

import 'package:flame/components.dart';

enum PowerUpType {
  rapidFire,
  shield,
  heal,
  coin,
}

class PowerUpItem extends PositionComponent {
  final double speed;
  final PowerUpType type;

  late final SpriteComponent itemSprite;

  double _rotationTimer = 0;

  PowerUpItem({
    required Vector2 position,
    required this.type,
    this.speed = 110,
  }) : super(
          position: position,
          size: _getItemSize(type),
          anchor: Anchor.center,
        );

  static Vector2 _getItemSize(PowerUpType type) {
    switch (type) {
      case PowerUpType.rapidFire:
        return Vector2(60, 60);
      case PowerUpType.shield:
        return Vector2(60, 60);
      case PowerUpType.heal:
        return Vector2(60, 60);
      case PowerUpType.coin:
        return Vector2(60, 60);
    }
  }

  String _getAssetName() {
    switch (type) {
      case PowerUpType.rapidFire:
        return 'rapid_fire.png';
      case PowerUpType.shield:
        return 'shield.png';
      case PowerUpType.heal:
        return 'heal.png';
      case PowerUpType.coin:
        return 'coins.png';
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    itemSprite = SpriteComponent(
      sprite: await Sprite.load(_getAssetName()),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );

    add(itemSprite);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    _rotationTimer += dt;
    final pulse = 1.0 + (math.sin(_rotationTimer * 6) * 0.06);
    scale = Vector2.all(pulse);

    if (position.y - (size.y / 2) > 900) {
      removeFromParent();
    }
  }
}