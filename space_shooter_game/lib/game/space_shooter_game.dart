import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter_game/models/mission.dart';
import 'package:space_shooter_game/models/player_weapon_type.dart';
import 'package:space_shooter_game/services/mission_service.dart';

import '../components/effects/explosion_effect.dart';
import '../components/enemies/boss_ship.dart';
import '../components/enemies/enemy_bullet.dart';
import '../components/enemies/enemy_ship.dart';
import '../components/enemies/tank_enemy_ship.dart';
import '../components/enemies/zigzag_enemy_ship.dart';
import '../components/player/player_bullet.dart';
import '../components/player/player_ship.dart';
import '../components/powerups/power_up_item.dart';
import '../services/progress_service.dart';

part 'space_shooter_game_hud.dart';
part 'space_shooter_game_spawning.dart';
part 'space_shooter_game_collisions.dart';
part 'space_shooter_game_flow.dart';

class SpaceShooterGame extends FlameGame {
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  final void Function(List<Mission>)? onMissionsCompleted;
  final int startingLevel;

  SpaceShooterGame({
    required this.onGameOver,
    required this.onLevelComplete,
    this.onMissionsCompleted,
    this.startingLevel = 1,
  });

  late PlayerShip player;

  late TextComponent scoreText;
  late TextComponent levelText;
  late TextComponent killText;
  late TextComponent livesText;
  late TextComponent powerText;
  late TextComponent transitionText;
  late TextComponent dropInfoText;

  final Random random = Random();

  int score = 0;

  int currentLevel = 1;
  int levelKillCount = 0;
  int levelTarget = 8;

  int lives = 3;
  int maxLives = 3;

  int missedEnemiesCount = 0;
  bool isLevelCompleted = false;

  bool isLevelTransition = false;
  double levelTransitionTimer = 0;
  double levelTransitionDuration = 2.0;

  bool isGameOver = false;

  bool isDamageCooldown = false;
  double damageCooldownTimer = 0;
  double damageCooldownDuration = 0.7;

  bool isRapidFireActive = false;
  double rapidFireTimer = 0;
  double rapidFireDuration = 5.0;

  bool previousShieldState = false;

  bool isBossSpawnedForLevel = false;
  BossShip? currentBoss;

  bool get isBossLevel => currentLevel % 5 == 0;

  double normalFireInterval = 0.35;
  double rapidFireInterval = 0.12;

  double fireTimer = 0;

  double enemySpawnTimer = 0;
  double enemySpawnInterval = 1.2;

  double enemyBulletSpawnTimer = 0;
  double enemyBulletSpawnInterval = 1.6;

  double powerUpSpawnTimer = 0;
  double powerUpSpawnInterval = 12.0;

  int comboCount = 0;
  int bestCombo = 0;
  double comboTimer = 0;
  double comboResetDuration = 2.2;

  bool get hasActiveCombo => comboCount > 1;

  void _applySelectedShipStats() {
    normalFireInterval = player.fireCooldown;
    rapidFireInterval = (player.fireCooldown * 0.55).clamp(0.10, 0.20);
  }

  void _registerComboKill() {
    comboCount++;
    comboTimer = 0;

    if (comboCount > bestCombo) {
      bestCombo = comboCount;
    }

    _updateHud();
  }

  void _resetCombo() {
    if (comboCount == 0) return;

    comboCount = 0;
    comboTimer = 0;
    _updateHud();
  }

  int getComboBonusScore() {
    if (comboCount <= 1) {
      return 0;
    }

    return comboCount - 1;
  }

  int getEarnedStars() {
    if (!isLevelCompleted) {
      return 0;
    }

    final int threeStarMissLimit = (levelTarget * 0.10).floor();
    final int twoStarMissLimit = (levelTarget * 0.30).floor();

    if (missedEnemiesCount <= threeStarMissLimit) {
      return 3;
    }

    if (missedEnemiesCount <= twoStarMissLimit) {
      return 2;
    }

    return 1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    currentLevel = startingLevel.clamp(1, 999);
    levelKillCount = 0;
    levelTarget = 8 + ((currentLevel - 1) * 4);

    missedEnemiesCount = 0;
    isLevelCompleted = false;

    enemySpawnInterval = (1.2 - ((currentLevel - 1) * 0.1)).clamp(0.5, 10.0);
    enemyBulletSpawnInterval =
        (1.6 - ((currentLevel - 1) * 0.08)).clamp(0.7, 10.0);

    isBossSpawnedForLevel = false;
    currentBoss = null;

    add(
      RectangleComponent(
        size: Vector2(size.x, size.y),
        paint: Paint()..color = const Color(0xFF090B1A),
      ),
    );

    add(
      TextComponent(
        text: 'Space Shooter',
        position: Vector2(size.x / 2, 20),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    _createHudTexts();

    final selectedShipStats = ProgressService.instance.getSelectedShipStats();

    player = PlayerShip(
      position: Vector2(size.x / 2, size.y - 70),
      shipStats: selectedShipStats,
    );

    add(player);

    _applySelectedShipStats();
    lives = maxLives;
    _updateHud();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) {
      return;
    }

    if (isDamageCooldown) {
      damageCooldownTimer += dt;
      if (damageCooldownTimer >= damageCooldownDuration) {
        isDamageCooldown = false;
        damageCooldownTimer = 0;
      }
    }

    if (isRapidFireActive) {
      rapidFireTimer += dt;
      if (rapidFireTimer >= rapidFireDuration) {
        isRapidFireActive = false;
        rapidFireTimer = 0;
        _updateHud();
      }
    }

    if (player.isShieldActive != previousShieldState) {
      previousShieldState = player.isShieldActive;
      _updateHud();
    }

    if (comboCount > 0) {
      comboTimer += dt;

      if (comboTimer >= comboResetDuration) {
        _resetCombo();
      }
    }

    if (isLevelTransition) {
      return;
    }

    if (isBossLevel && !isBossSpawnedForLevel) {
      _spawnBoss();
      isBossSpawnedForLevel = true;
      _updateHud();
    }

    fireTimer += dt;
    final currentFireInterval =
        isRapidFireActive ? rapidFireInterval : normalFireInterval;

    if (fireTimer >= currentFireInterval) {
      fireTimer = 0;
      _fireBullet();
    }

    if (!isBossLevel) {
      enemySpawnTimer += dt;
      if (enemySpawnTimer >= enemySpawnInterval) {
        enemySpawnTimer = 0;
        _spawnEnemy();
      }
    }

    enemyBulletSpawnTimer += dt;
    if (enemyBulletSpawnTimer >= enemyBulletSpawnInterval) {
      enemyBulletSpawnTimer = 0;
      _spawnEnemyBullet();
    }

    powerUpSpawnTimer += dt;
    if (powerUpSpawnTimer >= powerUpSpawnInterval) {
      powerUpSpawnTimer = 0;
      _spawnPowerUp();
    }

    _checkBulletEnemyCollisions();
    _checkEnemyPlayerCollisions();
    _checkEnemyBulletPlayerCollisions();
    _checkEnemiesPassedBottom();
    _checkPowerUpPlayerCollisions();
  }
}