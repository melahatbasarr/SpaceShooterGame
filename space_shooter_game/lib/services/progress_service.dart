import 'dart:math';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../data/storage_keys.dart';
import '../models/level_progress.dart';
import '../models/player_progress.dart';
import '../models/ship_stats.dart';

class ProgressService {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

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
    const freshProgress = PlayerProgress();

    await saveProgress(freshProgress);
  }
}