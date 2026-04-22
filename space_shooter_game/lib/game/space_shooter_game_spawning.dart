part of 'space_shooter_game.dart';

extension SpaceShooterGameSpawning on SpaceShooterGame {
  void _fireBullet() {
    final spawnPosition = player.getBulletSpawnPosition();
    final weaponType = player.shipStats.weaponType;

    switch (weaponType) {
      case PlayerWeaponType.single:
        add(
          PlayerBullet(
            position: spawnPosition.clone(),
          ),
        );
        break;

      case PlayerWeaponType.doubleShot:
        add(
          PlayerBullet(
            position: Vector2(spawnPosition.x - 14, spawnPosition.y),
            bulletColor: const Color(0xFFFFF176),
          ),
        );

        add(
          PlayerBullet(
            position: Vector2(spawnPosition.x + 14, spawnPosition.y),
            bulletColor: const Color(0xFFFFF176),
          ),
        );
        break;

      case PlayerWeaponType.heavy:
        add(
          PlayerBullet(
            position: spawnPosition.clone(),
            speed: 360,
            bulletSize: Vector2(10, 26),
            bulletColor: const Color(0xFFFFB74D),
          ),
        );
        break;

      case PlayerWeaponType.spread:
        add(
          PlayerBullet(
            position: spawnPosition.clone(),
            bulletColor: const Color(0xFF81D4FA),
          ),
        );

        add(
          PlayerBullet(
            position: Vector2(spawnPosition.x - 10, spawnPosition.y),
            horizontalSpeed: -140,
            bulletColor: const Color(0xFF81D4FA),
          ),
        );

        add(
          PlayerBullet(
            position: Vector2(spawnPosition.x + 10, spawnPosition.y),
            horizontalSpeed: 140,
            bulletColor: const Color(0xFF81D4FA),
          ),
        );
        break;

      case PlayerWeaponType.power:
        add(
          PlayerBullet(
            position: spawnPosition.clone(),
            speed: 430,
            bulletSize: Vector2(8, 24),
            bulletColor: const Color(0xFFCE93D8),
          ),
        );
        break;
    }
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
    const double itemWidth = 28;
    final double halfWidth = itemWidth / 2;

    final double randomX =
        halfWidth + random.nextDouble() * (size.x - itemWidth);

    final double roll = random.nextDouble();

    final PowerUpType randomType;
    if (roll < 0.35) {
      randomType = PowerUpType.rapidFire;
    } else if (roll < 0.60) {
      randomType = PowerUpType.shield;
    } else if (roll < 0.80) {
      randomType = PowerUpType.heal;
    } else {
      randomType = PowerUpType.coin;
    }

    add(
      PowerUpItem(
        position: Vector2(randomX, -20),
        type: randomType,
      ),
    );
  }
}