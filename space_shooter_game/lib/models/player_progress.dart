import 'level_progress.dart';

class PlayerProgress {
  final int highestUnlockedLevel;
  final int coins;
  final Map<int, LevelProgress> levelsProgress;

  const PlayerProgress({
    this.highestUnlockedLevel = 1,
    this.coins = 0,
    this.levelsProgress = const {},
  });

  LevelProgress getLevelProgress(int level) {
    return levelsProgress[level] ??
        LevelProgress(
          levelNumber: level,
        );
  }

  bool isLevelUnlocked(int level) {
    return level <= highestUnlockedLevel;
  }

  PlayerProgress copyWith({
    int? highestUnlockedLevel,
    int? coins,
    Map<int, LevelProgress>? levelsProgress,
  }) {
    return PlayerProgress(
      highestUnlockedLevel:
          highestUnlockedLevel ?? this.highestUnlockedLevel,
      coins: coins ?? this.coins,
      levelsProgress: levelsProgress ?? this.levelsProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'highestUnlockedLevel': highestUnlockedLevel,
      'coins': coins,
      'levelsProgress': levelsProgress.map(
        (key, value) => MapEntry(
          key.toString(),
          value.toMap(),
        ),
      ),
    };
  }

  factory PlayerProgress.fromMap(Map<dynamic, dynamic> map) {
    final rawLevelsProgress =
        (map['levelsProgress'] as Map<dynamic, dynamic>?) ?? {};

    final parsedLevelsProgress = <int, LevelProgress>{};

    for (final entry in rawLevelsProgress.entries) {
      final int level = int.tryParse(entry.key.toString()) ?? 1;
      final valueMap = entry.value as Map<dynamic, dynamic>;

      parsedLevelsProgress[level] = LevelProgress.fromMap(valueMap);
    }

    return PlayerProgress(
      highestUnlockedLevel: map['highestUnlockedLevel'] ?? 1,
      coins: map['coins'] ?? 0,
      levelsProgress: parsedLevelsProgress,
    );
  }
}