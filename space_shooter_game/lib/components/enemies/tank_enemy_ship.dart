import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'enemy_ship.dart';

class TankEnemyShip extends EnemyShip {
  TankEnemyShip({
    required Vector2 position,
    double speed = 85,
  }) : super(
         position: position,
         speed: speed,
         maxHealth: 3,
         scoreValue: 4,
         color: const Color(0xFFAB47BC),
         assetName: 'enemies_three.png',
       ) {
    size = Vector2(68, 30);
  }
}