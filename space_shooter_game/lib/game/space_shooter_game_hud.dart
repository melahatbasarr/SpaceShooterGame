part of 'space_shooter_game.dart';

extension SpaceShooterGameHud on SpaceShooterGame {
  void _createHudTexts() {
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x - 20, 70),
      anchor: Anchor.topRight,
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
    add(levelText);

    killText = TextComponent(
      text: 'Kills: 0 / 8',
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
    add(killText);

    livesText = TextComponent(
      text: '❤ ❤ ❤',
      position: Vector2(20, 130),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(livesText);

    powerText = TextComponent(
      text: '',
      position: Vector2(20, 165),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amberAccent,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    add(powerText);

    dropInfoText = TextComponent(
      text: '',
      position: Vector2(20, 192),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    add(dropInfoText);

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

    livesText.text = _buildLivesText();
    powerText.text = _buildStatusText();
    dropInfoText.text = _buildDropInfoText();
  }

  String _buildLivesText() {
    if (lives <= 0) {
      return '';
    }

    return List.generate(lives, (_) => '❤').join(' ');
  }

  String _buildStatusText() {
    final parts = <String>[];

    if (hasActiveCombo) {
      parts.add('Combo x$comboCount');
    }

    if (isRapidFireActive) {
      parts.add('Rapid Fire');
    }

    if (player.isShieldActive) {
      parts.add('Shield');
    }

    return parts.join('   •   ');
  }

  String _buildDropInfoText() {
    return 'Drops: Rapid Fire • Shield • Heal';
  }
}