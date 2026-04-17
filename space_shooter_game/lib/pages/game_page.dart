import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../services/progress_service.dart';

class GamePage extends StatefulWidget {
  final int level;

  const GamePage({
    super.key,
    required this.level,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late SpaceShooterGame game;

  bool showGameOverMenu = false;
  bool showLevelCompleteMenu = false;

  @override
  void initState() {
    super.initState();

    game = SpaceShooterGame(
      startingLevel: widget.level,
      onGameOver: () {
        if (!mounted) return;

        setState(() {
          showGameOverMenu = true;
          showLevelCompleteMenu = false;
        });
      },
      onLevelComplete: _handleLevelComplete,
    );
  }

  Future<void> _handleLevelComplete() async {
    if (showLevelCompleteMenu) return;

    final int earnedStars = game.getEarnedStars();

    await ProgressService.instance.completeLevel(
      level: widget.level,
      stars: earnedStars,
      score: game.score,
    );

    if (!mounted) return;

    setState(() {
      showLevelCompleteMenu = true;
      showGameOverMenu = false;
    });
  }

  void _restartLevel() {
    setState(() {
      showGameOverMenu = false;
      showLevelCompleteMenu = false;
    });

    game.restartGame();
  }

  void _goBackToLevelSelect() {
    Navigator.of(context).pop();
  }

  void _goToNextLevel() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GamePage(level: widget.level + 1),
      ),
    );
  }

  void _handlePlayerMove(double x) {
    if (!showGameOverMenu && !showLevelCompleteMenu) {
      game.movePlayerToX(x);
    }
  }

  Widget _buildStars(int earnedStars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool filled = index < earnedStars;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? Colors.amber : Colors.white54,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildGameOverMenu() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white24,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Level ${widget.level}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Score: ${game.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restartLevel,
                  child: const Text('Restart'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _goBackToLevelSelect,
                  child: const Text('Level Select'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCompleteMenu() {
    final int earnedStars = game.getEarnedStars();

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white24,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Level Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Level ${widget.level} cleared',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildStars(earnedStars),
              const SizedBox(height: 16),
              Text(
                'Score: ${game.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Missed Enemies: ${game.missedEnemiesCount}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextLevel,
                  child: const Text('Next Level'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _goBackToLevelSelect,
                  child: const Text('Level Select'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (details) {
                _handlePlayerMove(details.localPosition.dx);
              },
              onPanUpdate: (details) {
                _handlePlayerMove(details.localPosition.dx);
              },
              child: GameWidget(
                game: game,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: _goBackToLevelSelect,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          if (showGameOverMenu) Positioned.fill(child: _buildGameOverMenu()),
          if (showLevelCompleteMenu)
            Positioned.fill(child: _buildLevelCompleteMenu()),
        ],
      ),
    );
  }
}