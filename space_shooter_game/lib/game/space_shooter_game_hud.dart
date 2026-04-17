part of 'space_shooter_game.dart';

extension SpaceShooterGameHud on SpaceShooterGame {
  void _createHudTexts() {
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 70),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(scoreText);

    levelText = TextComponent(
      text: 'Level: 1',
      position: Vector2(20, 100),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(levelText);

    killText = TextComponent(
      text: 'Kills: 0 / 8',
      position: Vector2(20, 130),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(killText);

    livesText = TextComponent(
      text: 'Lives: 3',
      position: Vector2(20, 160),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(livesText);

    powerText = TextComponent(
      text: 'Power: Normal',
      position: Vector2(20, 190),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(powerText);

    transitionText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(transitionText);
  }

  void _updateHud() {
    scoreText.text = 'Score: $score';
    levelText.text = 'Level: $currentLevel';

    if (isBossLevel && currentBoss != null) {
      killText.text =
          'Boss HP: ${currentBoss!.health} / ${currentBoss!.maxHealth}';
    } else {
      killText.text = 'Kills: $levelKillCount / $levelTarget';
    }

    livesText.text = 'Lives: $lives';
    powerText.text = _getPowerText();
  }

  String _getPowerText() {
    if (isRapidFireActive && player.isShieldActive) {
      return 'Power: Rapid Fire + Shield';
    }

    if (isRapidFireActive) {
      return 'Power: Rapid Fire';
    }

    if (player.isShieldActive) {
      return 'Power: Shield';
    }

    return 'Power: Normal';
  }
}