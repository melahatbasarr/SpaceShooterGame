import 'package:flutter/material.dart';

import '../services/progress_service.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int currentLevel;
  final VoidCallback onRestart;
  final VoidCallback onBackToLevels;
  final VoidCallback? onNextLevel;

  const LevelCompleteOverlay({
    super.key,
    required this.currentLevel,
    required this.onRestart,
    required this.onBackToLevels,
    this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastLevel = currentLevel >= ProgressService.maxLevel;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF101828),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white24,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLastLevel ? 'All Levels Completed' : 'Level Complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isLastLevel
                    ? 'You reached the final level.'
                    : 'Get ready for the next battle.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!isLastLevel && onNextLevel != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNextLevel,
                    child: const Text('Next Level'),
                  ),
                ),
              if (isLastLevel)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBackToLevels,
                    child: const Text('Back to Levels'),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onRestart,
                  child: const Text('Restart Level'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}