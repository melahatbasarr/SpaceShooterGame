import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerShip extends RectangleComponent {
  late final Paint _normalPaint;
  late final Paint _shieldPaint;

  late final CircleComponent shieldRing;

  bool isShieldActive = false;
  double shieldTimer = 0;
  double shieldDuration = 5.0;
  double shieldPulseTimer = 0;

  PlayerShip({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(72, 24),
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF4DD0E1),
        ) {
    _normalPaint = Paint()..color = const Color(0xFF4DD0E1);
    _shieldPaint = Paint()..color = const Color(0xFF81D4FA);

    paint = _normalPaint;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    shieldRing = CircleComponent(
      position: size / 2,
      radius: 42,
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    add(shieldRing);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isShieldActive) {
      shieldTimer += dt;
      shieldPulseTimer += dt;

      final double pulse = 1.0 + (math.sin(shieldPulseTimer * 8) * 0.08);
      shieldRing.scale = Vector2.all(pulse);

      if (shieldTimer >= shieldDuration) {
        deactivateShield();
      }
    }
  }

  void moveToX(double x, double screenWidth) {
    final double halfWidth = size.x / 2;

    final double clampedX = x.clamp(
      halfWidth,
      screenWidth - halfWidth,
    );

    position.x = clampedX;
  }

  Vector2 getBulletSpawnPosition() {
    return Vector2(
      position.x,
      position.y - (size.y / 2) - 10,
    );
  }

  void activateShield({double duration = 5.0}) {
    isShieldActive = true;
    shieldDuration = duration;
    shieldTimer = 0;
    shieldPulseTimer = 0;

    paint = _shieldPaint;
    shieldRing.paint.color = const Color(0xAA64B5F6);
    shieldRing.scale = Vector2.all(1.0);
  }

  void deactivateShield() {
    isShieldActive = false;
    shieldTimer = 0;
    shieldPulseTimer = 0;

    paint = _normalPaint;
    shieldRing.paint.color = Colors.transparent;
    shieldRing.scale = Vector2.all(1.0);
  }
}