part of 'space_shooter_game.dart';

extension SpaceShooterGameCollisions on SpaceShooterGame {
  void _checkBulletEnemyCollisions() {
    final bullets = children.whereType<PlayerBullet>().toList();
    final enemies = children.whereType<EnemyShip>().toList();

    for (final bullet in bullets) {
      for (final enemy in enemies) {
        if (_isOverlapping(bullet, enemy)) {
          bullet.removeFromParent();

          final bool isDestroyed = enemy.takeHit(
            damage: player.bulletDamage,
          );

          if (isDestroyed) {
            add(
              ExplosionEffect(
                position: enemy.position.clone(),
              ),
            );

            final bool isBoss = enemy is BossShip;

            enemy.removeFromParent();
            levelKillCount++;

            _registerComboKill();
            final int comboBonus = getComboBonusScore();
            score += enemy.scoreValue + comboBonus;

            MissionService.instance.addProgress(
              type: MissionType.killEnemies,
              amount: 1,
            );

            if (isBoss) {
              MissionService.instance.addProgress(
                type: MissionType.killBosses,
                amount: 1,
              );
            }

            _updateHud();

            if (isBoss) {
              _completeLevel();
            } else if (levelKillCount >= levelTarget) {
              _completeLevel();
            }
          }

          break;
        }
      }
    }
  }

  void _checkEnemyPlayerCollisions() {
    if (isDamageCooldown || isLevelTransition) return;

    final enemies = children.whereType<EnemyShip>().toList();

    for (final enemy in enemies) {
      if (_isOverlapping(enemy, player)) {
        add(
          ExplosionEffect(
            position: enemy.position.clone(),
          ),
        );

        enemy.removeFromParent();
        _takeDamage();
        return;
      }
    }
  }

  void _checkEnemyBulletPlayerCollisions() {
    if (isDamageCooldown || isLevelTransition) return;

    final enemyBullets = children.whereType<EnemyBullet>().toList();

    for (final bullet in enemyBullets) {
      if (_isOverlapping(bullet, player)) {
        bullet.removeFromParent();
        _takeDamage();
        return;
      }
    }
  }

  void _checkEnemiesPassedBottom() {
    final enemies = children.whereType<EnemyShip>().toList();

    for (final enemy in enemies) {
      if (enemy.position.y - (enemy.size.y / 2) > size.y) {
        enemy.removeFromParent();
        missedEnemiesCount++;
        _takeDamage();
        return;
      }
    }
  }

  void _checkPowerUpPlayerCollisions() {
    if (isLevelTransition) return;

    final powerUps = children.whereType<PowerUpItem>().toList();

    for (final item in powerUps) {
      if (_isOverlapping(item, player)) {
        item.removeFromParent();

        MissionService.instance.addProgress(
          type: MissionType.collectPowerUps,
          amount: 1,
        );

        switch (item.type) {
          case PowerUpType.rapidFire:
            _activateRapidFire();
            break;

          case PowerUpType.shield:
            player.activateShield();
            _updateHud();
            break;

          case PowerUpType.heal:
            lives = min(lives + 1, maxLives);
            _updateHud();
            break;

          case PowerUpType.coin:
            ProgressService.instance.addCoins(1);
            _updateHud();
            break;
        }

        return;
      }
    }
  }

  bool _isOverlapping(PositionComponent a, PositionComponent b) {
    final aLeft = a.position.x - a.size.x / 2;
    final aRight = a.position.x + a.size.x / 2;
    final aTop = a.position.y - a.size.y / 2;
    final aBottom = a.position.y + a.size.y / 2;

    final bLeft = b.position.x - b.size.x / 2;
    final bRight = b.position.x + b.size.x / 2;
    final bTop = b.position.y - b.size.y / 2;
    final bBottom = b.position.y + b.size.y / 2;

    return aLeft < bRight &&
        aRight > bLeft &&
        aTop < bBottom &&
        aBottom > bTop;
  }
}