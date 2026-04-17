import 'dart:math';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../data/storage_keys.dart';
import '../models/level_progress.dart';
import '../models/player_progress.dart';

class ProgressService {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  Box<dynamic> get _box => Hive.box(StorageKeys.playerProgressBox);

  Future<void> init() async {
    await Hive.openBox(StorageKeys.playerProgressBox);

    if (!_box.containsKey(StorageKeys.playerProgressKey)) {
      final initialProgress = PlayerProgress(
        highestUnlockedLevel: 1,
        coins: 0,
        levelsProgress: const {},
      );

      await _box.put(
        StorageKeys.playerProgressKey,
        initialProgress.toMap(),
      );
    }
  }

  PlayerProgress loadProgress() {
    final rawData = _box.get(StorageKeys.playerProgressKey);

    if (rawData is Map<dynamic, dynamic>) {
      return PlayerProgress.fromMap(rawData);
    }

    return const PlayerProgress();
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    await _box.put(
      StorageKeys.playerProgressKey,
      progress.toMap(),
    );
  }

  bool isLevelUnlocked(int level) {
    final progress = loadProgress();
    return progress.isLevelUnlocked(level);
  }

  int getStarsForLevel(int level) {
    final progress = loadProgress();
    return progress.getLevelProgress(level).stars;
  }

  int getBestScoreForLevel(int level) {
    final progress = loadProgress();
    return progress.getLevelProgress(level).bestScore;
  }

  int getHighestUnlockedLevel() {
    final progress = loadProgress();
    return progress.highestUnlockedLevel;
  }

  int getCoins() {
    final progress = loadProgress();
    return progress.coins;
  }

  Future<void> addCoins(int amount) async {
    final progress = loadProgress();

    final updatedProgress = progress.copyWith(
      coins: progress.coins + amount,
    );

    await saveProgress(updatedProgress);
  }

  Future<void> completeLevel({
    required int level,
    required int stars,
    required int score,
  }) async {
    final progress = loadProgress();

    final currentLevelProgress = progress.getLevelProgress(level);

    final updatedLevelProgress = currentLevelProgress.copyWith(
      levelNumber: level,
      stars: max(currentLevelProgress.stars, stars),
      bestScore: max(currentLevelProgress.bestScore, score),
      isCompleted: true,
    );

    final updatedLevelsProgress =
        Map<int, LevelProgress>.from(progress.levelsProgress);
    updatedLevelsProgress[level] = updatedLevelProgress;

    final updatedHighestUnlockedLevel = max(
      progress.highestUnlockedLevel,
      level + 1,
    );

    final updatedProgress = progress.copyWith(
      highestUnlockedLevel: updatedHighestUnlockedLevel,
      levelsProgress: updatedLevelsProgress,
    );

    await saveProgress(updatedProgress);
  }

  Future<void> resetProgress() async {
    const freshProgress = PlayerProgress(
      highestUnlockedLevel: 1,
      coins: 0,
      levelsProgress: {},
    );

    await saveProgress(freshProgress);
  }
}