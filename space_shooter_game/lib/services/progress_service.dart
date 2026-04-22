import 'dart:math';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../data/storage_keys.dart';
import '../models/level_progress.dart';
import '../models/player_progress.dart';
import '../models/ship_stats.dart';

class ProgressService {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  static const int maxLevel = 20;

  Box<dynamic> get _box => Hive.box(StorageKeys.playerProgressBox);

  Future<void> init() async {
    await Hive.openBox(StorageKeys.playerProgressBox);

    if (!_box.containsKey(StorageKeys.playerProgressKey)) {
      const initialProgress = PlayerProgress();

      await _box.put(
        StorageKeys.playerProgressKey,
        initialProgress.toMap(),
      );
    }
  }

  PlayerProgress loadProgress() {
    final rawData = _box.get(StorageKeys.playerProgressKey);

    if (rawData is Map<dynamic, dynamic>) {
      final progress = PlayerProgress.fromMap(rawData);

      return progress.copyWith(
        highestUnlockedLevel: progress.highestUnlockedLevel.clamp(1, maxLevel),
      );
    }

    return const PlayerProgress();
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    await _box.put(
      StorageKeys.playerProgressKey,
      progress.copyWith(
        highestUnlockedLevel: progress.highestUnlockedLevel.clamp(1, maxLevel),
      ).toMap(),
    );
  }

  bool isLevelUnlocked(int level) {
    if (level < 1 || level > maxLevel) {
      return false;
    }

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
    return progress.highestUnlockedLevel.clamp(1, maxLevel);
  }

  int getCoins() {
    final progress = loadProgress();
    return progress.coins;
  }

  List<String> getOwnedShipIds() {
    final progress = loadProgress();
    return List<String>.from(progress.ownedShipIds);
  }

  String getSelectedShipId() {
    final progress = loadProgress();
    return progress.selectedShipId;
  }

  ShipStats getSelectedShipStats() {
    final progress = loadProgress();
    return ShipCatalog.getById(progress.selectedShipId);
  }

  bool isShipOwned(String shipId) {
    final progress = loadProgress();
    return progress.isShipOwned(shipId);
  }

  bool hasNextLevel(int currentLevel) {
    return currentLevel < maxLevel;
  }

  int getNextLevel(int currentLevel) {
    return min(currentLevel + 1, maxLevel);
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    final progress = loadProgress();

    final updatedProgress = progress.copyWith(
      coins: progress.coins + amount,
    );

    await saveProgress(updatedProgress);
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) {
      return true;
    }

    final progress = loadProgress();

    if (progress.coins < amount) {
      return false;
    }

    final updatedProgress = progress.copyWith(
      coins: progress.coins - amount,
    );

    await saveProgress(updatedProgress);
    return true;
  }

  Future<void> unlockShip(String shipId) async {
    final exists = ShipCatalog.all.any((ship) => ship.id == shipId);
    if (!exists) return;

    final progress = loadProgress();

    if (progress.ownedShipIds.contains(shipId)) {
      return;
    }

    final updatedOwnedShipIds = List<String>.from(progress.ownedShipIds)
      ..add(shipId);

    final updatedProgress = progress.copyWith(
      ownedShipIds: updatedOwnedShipIds,
    );

    await saveProgress(updatedProgress);
  }

  Future<bool> selectShip(String shipId) async {
    final progress = loadProgress();

    if (!progress.ownedShipIds.contains(shipId)) {
      return false;
    }

    final updatedProgress = progress.copyWith(
      selectedShipId: shipId,
    );

    await saveProgress(updatedProgress);
    return true;
  }

  Future<void> completeLevel({
    required int level,
    required int stars,
    required int score,
  }) async {
    final progress = loadProgress();
    final safeLevel = level.clamp(1, maxLevel);

    final currentLevelProgress = progress.getLevelProgress(safeLevel);

    final updatedLevelProgress = currentLevelProgress.copyWith(
      levelNumber: safeLevel,
      stars: max(currentLevelProgress.stars, stars),
      bestScore: max(currentLevelProgress.bestScore, score),
      isCompleted: true,
    );

    final updatedLevelsProgress =
        Map<int, LevelProgress>.from(progress.levelsProgress);
    updatedLevelsProgress[safeLevel] = updatedLevelProgress;

    final updatedHighestUnlockedLevel = min(
      max(progress.highestUnlockedLevel, safeLevel + 1),
      maxLevel,
    );

    final updatedProgress = progress.copyWith(
      highestUnlockedLevel: updatedHighestUnlockedLevel,
      levelsProgress: updatedLevelsProgress,
    );

    await saveProgress(updatedProgress);
  }

  Future<void> resetProgress() async {
    const freshProgress = PlayerProgress();

    await saveProgress(freshProgress);
  }
}