part of 'space_shooter_game.dart';

extension SpaceShooterGameSpawning on SpaceShooterGame {
  void _fireBullet() {
    add(
      PlayerBullet(
        position: player.getBulletSpawnPosition(),
      ),
    );
  }

  void _spawnBoss() {
    if (currentBoss != null) {
      return;
    }

    currentBoss = BossShip(
      position: Vector2(size.x / 2, -60),
      minX: 0,
      maxX: size.x,
      speed: 80 + ((currentLevel - 1) * 4),
      horizontalSpeed: 120 + ((currentLevel - 1) * 6),
    );

    add(currentBoss!);
  }

  void _spawnEnemy() {
    if (currentLevel == 5) {
      _spawnBoss();
      return;
    }

    final double spawnRoll = random.nextDouble();

    if (currentLevel >= 3 && spawnRoll < 0.20) {
      const double tankWidth = 68;
      final double halfWidth = tankWidth / 2;

      final double randomX =
          halfWidth + random.nextDouble() * (size.x - tankWidth);

      add(
        TankEnemyShip(
          position: Vector2(randomX, -20),
          speed: 85 + ((currentLevel - 1) * 8),
        ),
      );
      return;
    }

    if (currentLevel >= 2 && spawnRoll < 0.55) {
      const double zigzagWidth = 52;
      final double halfWidth = zigzagWidth / 2;

      final double randomX =
          halfWidth + random.nextDouble() * (size.x - zigzagWidth);

      add(
        ZigzagEnemyShip(
          position: Vector2(randomX, -20),
          minX: 0,
          maxX: size.x,
          speed: 120 + ((currentLevel - 1) * 20),
          horizontalSpeed: 90 + ((currentLevel - 1) * 10),
        ),
      );
      return;
    }

    const double enemyWidth = 52;
    final double halfWidth = enemyWidth / 2;

    final double randomX =
        halfWidth + random.nextDouble() * (size.x - enemyWidth);

    add(
      EnemyShip(
        position: Vector2(randomX, -20),
        speed: 120 + ((currentLevel - 1) * 20),
      ),
    );
  }

  void _spawnEnemyBullet() {
    final enemies = children.whereType<EnemyShip>().toList();
    if (enemies.isEmpty) return;

    final shooter = enemies[random.nextInt(enemies.length)];

    add(
      EnemyBullet(
        position: Vector2(
          shooter.position.x,
          shooter.position.y + (shooter.size.y / 2) + 12,
        ),
        speed: 240 + ((currentLevel - 1) * 15),
      ),
    );
  }

  void _spawnPowerUp() {
    const double itemWidth = 24;
    final double halfWidth = itemWidth / 2;

    final double randomX =
        halfWidth + random.nextDouble() * (size.x - itemWidth);

    final double roll = random.nextDouble();

    final PowerUpType randomType;
    if (roll < 0.50) {
      randomType = PowerUpType.rapidFire;
    } else if (roll < 0.80) {
      randomType = PowerUpType.shield;
    } else {
      randomType = PowerUpType.heal;
    }

    add(
      PowerUpItem(
        position: Vector2(randomX, -20),
        type: randomType,
      ),
    );
  }
}