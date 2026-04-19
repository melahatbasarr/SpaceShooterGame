part of 'space_shooter_game.dart';

extension SpaceShooterGameFlow on SpaceShooterGame {
  void movePlayerToX(double x) {
    if (isGameOver || isLevelTransition) return;
    player.moveToX(x, size.x);
  }

  void _activateRapidFire() {
    isRapidFireActive = true;
    rapidFireTimer = 0;
    _updateHud();
  }

  void _takeDamage() {
    if (isGameOver || isLevelTransition) return;

    _resetCombo();

    lives--;
    _updateHud();

    isDamageCooldown = true;
    damageCooldownTimer = 0;

    if (lives <= 0) {
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    if (isGameOver) return;

    _resetCombo();

    isGameOver = true;
    isLevelCompleted = false;
    currentBoss = null;
    isBossSpawnedForLevel = false;

    transitionText.text = 'Game Over';

    for (final enemy in children.whereType<EnemyShip>().toList()) {
      enemy.removeFromParent();
    }

    for (final bullet in children.whereType<PlayerBullet>().toList()) {
      bullet.removeFromParent();
    }

    for (final enemyBullet in children.whereType<EnemyBullet>().toList()) {
      enemyBullet.removeFromParent();
    }

    for (final item in children.whereType<PowerUpItem>().toList()) {
      item.removeFromParent();
    }

    onGameOver();
  }

  void _completeLevel() {
    if (isGameOver || isLevelTransition) return;

    _resetCombo();

    isLevelTransition = true;
    isLevelCompleted = true;
    levelTransitionTimer = 0;

    if (isBossLevel) {
      transitionText.text = 'Boss Defeated';
    } else {
      transitionText.text = 'Level Complete';
    }

    currentBoss = null;
    isBossSpawnedForLevel = false;

    for (final enemy in children.whereType<EnemyShip>().toList()) {
      enemy.removeFromParent();
    }

    for (final bullet in children.whereType<PlayerBullet>().toList()) {
      bullet.removeFromParent();
    }

    for (final enemyBullet in children.whereType<EnemyBullet>().toList()) {
      enemyBullet.removeFromParent();
    }

    for (final item in children.whereType<PowerUpItem>().toList()) {
      item.removeFromParent();
    }

    onLevelComplete();
  }

  void restartGame() {
    _resetCombo();

    score = 0;
    currentLevel = startingLevel;
    levelKillCount = 0;
    levelTarget = 8 + ((currentLevel - 1) * 4);

    _applySelectedShipStats();
    lives = maxLives;

    missedEnemiesCount = 0;
    isLevelCompleted = false;

    fireTimer = 0;

    enemySpawnTimer = 0;
    enemySpawnInterval = (1.2 - ((currentLevel - 1) * 0.1)).clamp(0.5, 10.0);

    enemyBulletSpawnTimer = 0;
    enemyBulletSpawnInterval = (1.6 - ((currentLevel - 1) * 0.08)).clamp(
      0.7,
      10.0,
    );

    powerUpSpawnTimer = 0;

    isGameOver = false;
    isLevelTransition = false;
    levelTransitionTimer = 0;

    isDamageCooldown = false;
    damageCooldownTimer = 0;

    isRapidFireActive = false;
    rapidFireTimer = 0;

    currentBoss = null;
    isBossSpawnedForLevel = false;

    previousShieldState = false;
    player.deactivateShield();

    transitionText.text = '';

    for (final enemy in children.whereType<EnemyShip>().toList()) {
      enemy.removeFromParent();
    }

    for (final bullet in children.whereType<PlayerBullet>().toList()) {
      bullet.removeFromParent();
    }

    for (final enemyBullet in children.whereType<EnemyBullet>().toList()) {
      enemyBullet.removeFromParent();
    }

    for (final item in children.whereType<PowerUpItem>().toList()) {
      item.removeFromParent();
    }

    player.snapToX(size.x / 2, size.x);
    player.position.y = size.y - 70;

    _updateHud();
  }
}
