part of 'space_shooter_game.dart';

extension SpaceShooterGameHud on SpaceShooterGame {
  void _createHudTexts() {
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
    levelText.text = 'Level: $currentLevel';

    if (isBossLevel && currentBoss != null) {
      killText.text =
          'Boss HP: ${currentBoss!.health} / ${currentBoss!.maxHealth}';
    } else {
      killText.text = 'Kills: $levelKillCount / $levelTarget';
    }

    livesText.text = _buildLivesText();
  }

  String _buildLivesText() {
    if (lives <= 0) {
      return '';
    }

    return List.generate(lives, (_) => '❤').join(' ');
  }
}