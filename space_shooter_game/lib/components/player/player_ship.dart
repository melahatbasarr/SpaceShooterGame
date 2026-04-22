import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../models/ship_stats.dart';

class PlayerShip extends RectangleComponent {
  final ShipStats shipStats;

  late final Paint _normalPaint;
  late final Paint _shieldPaint;

  late final CircleComponent shieldRing;
  PositionComponent? shipVisual;

  bool isShieldActive = false;
  double shieldTimer = 0;
  double shieldDuration = 5.0;
  double shieldPulseTimer = 0;

  double? _targetX;

  PlayerShip({
    required Vector2 position,
    ShipStats? shipStats,
  }) : shipStats = shipStats ?? ShipCatalog.starter,
       super(
         position: position,
         size: _getShipSize(shipStats ?? ShipCatalog.starter),
         anchor: Anchor.center,
         paint: Paint()..color = Colors.transparent,
       ) {
    final baseColor = _getBaseColor(this.shipStats.id);

    _normalPaint = Paint()..color = baseColor;
    _shieldPaint = Paint()..color = _getShieldColor(baseColor);

    _targetX = position.x;
  }

  int get maxHealth => shipStats.maxHealth;
  double get moveSpeed => shipStats.moveSpeed;
  double get fireCooldown => shipStats.fireCooldown;
  int get bulletDamage => shipStats.bulletDamage;

  static Vector2 _getShipSize(ShipStats shipStats) {
    switch (shipStats.id) {
      case 'rapid':
        return Vector2(68, 22);
      case 'tank':
        return Vector2(82, 28);
      case 'reaper':
        return Vector2(76, 24);
      case 'tempest':
        return Vector2(74, 24);
      case 'starter':
      default:
        return Vector2(72, 24);
    }
  }

  static Vector2 _getShipVisualSize(ShipStats shipStats) {
    switch (shipStats.id) {
      case 'rapid':
        return Vector2(72, 72);
      case 'tank':
        return Vector2(92, 92);
      case 'reaper':
        return Vector2(82, 82);
      case 'tempest':
        return Vector2(82, 82);
      case 'starter':
      default:
        return Vector2(78, 78);
    }
  }

  static Color _getBaseColor(String shipId) {
    switch (shipId) {
      case 'rapid':
        return const Color(0xFFFF8A65);
      case 'tank':
        return const Color(0xFF66BB6A);
      case 'reaper':
        return const Color(0xFFAB47BC);
      case 'tempest':
        return const Color(0xFF42A5F5);
      case 'starter':
      default:
        return const Color(0xFF4DD0E1);
    }
  }

  static Color _getShieldColor(Color baseColor) {
    return Color.lerp(baseColor, Colors.white, 0.35) ?? baseColor;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _createShipVisual();

    final double shieldRadius = (math.max(size.x, size.y) / 2) + 18;

    shieldRing = CircleComponent(
      position: size / 2,
      radius: shieldRadius,
      anchor: Anchor.center,
      priority: 10,
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    add(shieldRing);
  }

  Future<void> _createShipVisual() async {
    try {
      final sprite = await Sprite.load(shipStats.assetName);

      shipVisual = SpriteComponent(
        sprite: sprite,
        size: _getShipVisualSize(shipStats),
        anchor: Anchor.center,
        position: size / 2,
        priority: 1,
      );

      await add(shipVisual!);
    } catch (_) {
      shipVisual = RectangleComponent(
        size: _getShipVisualSize(shipStats) * 0.75,
        anchor: Anchor.center,
        position: size / 2,
        priority: 1,
        paint: _normalPaint,
      );

      await add(shipVisual!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_targetX != null) {
      final double distance = _targetX! - position.x;
      final double step = moveSpeed * dt;

      if (distance.abs() <= step) {
        position.x = _targetX!;
      } else {
        position.x += distance.sign * step;
      }
    }

    if (isShieldActive) {
      shieldTimer += dt;
      shieldPulseTimer += dt;

      final double pulse = 1.0 + (math.sin(shieldPulseTimer * 8) * 0.08);
      shieldRing.scale = Vector2.all(pulse);

      if (shipVisual != null) {
        final double visualPulse =
            1.0 + (math.sin(shieldPulseTimer * 8) * 0.03);
        shipVisual!.scale = Vector2.all(visualPulse);
      }

      if (shieldTimer >= shieldDuration) {
        deactivateShield();
      }
    }
  }

  void moveToX(double x, double screenWidth) {
    final double halfWidth = size.x / 2;

    _targetX = x.clamp(
      halfWidth,
      screenWidth - halfWidth,
    );
  }

  void snapToX(double x, double screenWidth) {
    final double halfWidth = size.x / 2;

    final double clampedX = x.clamp(
      halfWidth,
      screenWidth - halfWidth,
    );

    position.x = clampedX;
    _targetX = clampedX;
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

    shieldRing.paint.color = const Color(0xAA64B5F6);
    shieldRing.scale = Vector2.all(1.0);

    if (shipVisual is RectangleComponent) {
      (shipVisual as RectangleComponent).paint = _shieldPaint;
    }
  }

  void deactivateShield() {
    isShieldActive = false;
    shieldTimer = 0;
    shieldPulseTimer = 0;

    shieldRing.paint.color = Colors.transparent;
    shieldRing.scale = Vector2.all(1.0);

    if (shipVisual != null) {
      shipVisual!.scale = Vector2.all(1.0);
    }

    if (shipVisual is RectangleComponent) {
      (shipVisual as RectangleComponent).paint = _normalPaint;
    }
  }
}