import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';
import '../services/progress_service.dart';

class GamePage extends StatefulWidget {
  final int level;

  const GamePage({super.key, required this.level});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _MissionToastData {
  final int id;
  final String title;

  const _MissionToastData({
    required this.id,
    required this.title,
  });
}

class _GamePageState extends State<GamePage> {
  late SpaceShooterGame game;

  bool showGameOverMenu = false;
  bool showLevelCompleteMenu = false;
  bool isSavingLevelResult = false;

  int earnedCoinsForCurrentClear = 0;

  int _toastIdCounter = 0;
  final List<_MissionToastData> _missionToasts = [];

  @override
  void initState() {
    super.initState();

    game = SpaceShooterGame(
      startingLevel: widget.level,
      onGameOver: () {
        if (!mounted) return;
        if (showLevelCompleteMenu) return;

        setState(() {
          showGameOverMenu = true;
          showLevelCompleteMenu = false;
        });
      },
      onLevelComplete: _handleLevelComplete,
      onMissionsCompleted: _showMissionCompletedToast,
    );

    _startLevelMusicIfNeeded();
  }

  Future<void> _startLevelMusicIfNeeded() async {
    if (widget.level != 5) return;

    await FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('ses.mp3', volume: 1.0);
  }

  int _calculateCoinReward(int earnedStars) {
    final int baseReward = 20 + (widget.level * 5);
    final int starBonus = earnedStars * 10;

    return baseReward + starBonus;
  }

  void _showMissionCompletedToast(List<Mission> missions) {
    if (!mounted) return;
    if (missions.isEmpty) return;

    for (final mission in missions) {
      _enqueueMissionToast(mission.title);
    }
  }

  void _enqueueMissionToast(String missionTitle) {
    final toast = _MissionToastData(
      id: _toastIdCounter++,
      title: missionTitle,
    );

    setState(() {
      _missionToasts.add(toast);
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;

      setState(() {
        _missionToasts.removeWhere((item) => item.id == toast.id);
      });
    });
  }

  Future<void> _handleLevelComplete() async {
    if (!mounted) return;
    if (isSavingLevelResult) return;
    if (showGameOverMenu) return;
    if (showLevelCompleteMenu) return;
    if (game.isGameOver) return;
    if (!game.isLevelCompleted) return;

    isSavingLevelResult = true;

    final int earnedStars = game.getEarnedStars();
    final int earnedCoins = _calculateCoinReward(earnedStars);

    await ProgressService.instance.addCoins(earnedCoins);

    await ProgressService.instance.completeLevel(
      level: widget.level,
      stars: earnedStars,
      score: game.score,
    );

    final completedMissions =
        await MissionService.instance.registerLevelCompleted(
      withoutMiss: game.missedEnemiesCount == 0,
    );

    if (completedMissions.isNotEmpty) {
      _showMissionCompletedToast(completedMissions);
    }

    if (!mounted) return;

    setState(() {
      earnedCoinsForCurrentClear = earnedCoins;
      showLevelCompleteMenu = true;
      showGameOverMenu = false;
    });

    isSavingLevelResult = false;
  }

  Future<bool> _showExitConfirmDialog() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text(
            'Exit Game',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Do you want to return to the level select screen?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  Future<void> _tryExitGame() async {
    final bool shouldExit = await _showExitConfirmDialog();

    if (!mounted) return;

    if (shouldExit) {
      _goBackToLevelSelect();
    }
  }

  void _restartLevel() {
    setState(() {
      showGameOverMenu = false;
      showLevelCompleteMenu = false;
      isSavingLevelResult = false;
      earnedCoinsForCurrentClear = 0;
      _missionToasts.clear();
    });

    game.restartGame();
  }

  void _goBackToLevelSelect() {
    FlameAudio.bgm.stop();
    Navigator.of(context).pop();
  }

  void _goToNextLevel() {
    FlameAudio.bgm.stop();

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

  Widget _buildTopExitButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _tryExitGame,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionToastLayer() {
    if (_missionToasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.only(top: 54, left: 16, right: 52),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _missionToasts.map((toast) {
                return AnimatedContainer(
                  key: ValueKey(toast.id),
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10261B).withOpacity(0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF35D07F).withOpacity(0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E8E5A).withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF35D07F),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Mission Completed!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              toast.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
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
            border: Border.all(color: Colors.white24),
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
            border: Border.all(color: Colors.white24),
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
              const SizedBox(height: 8),
              Text(
                'Coins Earned: +$earnedCoinsForCurrentClear',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
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
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _tryExitGame();
        return false;
      },
      child: Scaffold(
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
                child: GameWidget(game: game),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: _buildTopExitButton(),
              ),
            ),
            Positioned.fill(
              child: _buildMissionToastLayer(),
            ),
            if (showGameOverMenu)
              Positioned.fill(child: _buildGameOverMenu()),
            if (showLevelCompleteMenu)
              Positioned.fill(child: _buildLevelCompleteMenu()),
          ],
        ),
      ),
    );
  }
}