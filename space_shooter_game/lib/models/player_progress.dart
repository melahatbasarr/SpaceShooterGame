import 'level_progress.dart';
import 'mission_progress.dart';
import 'ship_stats.dart';

class PlayerProgress {
  final int highestUnlockedLevel;
  final int coins;
  final Map<int, LevelProgress> levelsProgress;
  final List<String> ownedShipIds;
  final String selectedShipId;
  final Map<String, MissionProgress> missionsProgress;

  const PlayerProgress({
    this.highestUnlockedLevel = 1,
    this.coins = 0,
    this.levelsProgress = const {},
    this.ownedShipIds = const [ShipCatalog.defaultShipId],
    this.selectedShipId = ShipCatalog.defaultShipId,
    this.missionsProgress = const {},
  });

  LevelProgress getLevelProgress(int level) {
    return levelsProgress[level] ??
        LevelProgress(
          levelNumber: level,
        );
  }

  MissionProgress getMissionProgress(String missionId) {
    return missionsProgress[missionId] ??
        MissionProgress(
          missionId: missionId,
        );
  }

  bool isLevelUnlocked(int level) {
    return level <= highestUnlockedLevel;
  }

  bool isShipOwned(String shipId) {
    return ownedShipIds.contains(shipId);
  }

  PlayerProgress copyWith({
    int? highestUnlockedLevel,
    int? coins,
    Map<int, LevelProgress>? levelsProgress,
    List<String>? ownedShipIds,
    String? selectedShipId,
    Map<String, MissionProgress>? missionsProgress,
  }) {
    return PlayerProgress(
      highestUnlockedLevel:
          highestUnlockedLevel ?? this.highestUnlockedLevel,
      coins: coins ?? this.coins,
      levelsProgress: levelsProgress ?? this.levelsProgress,
      ownedShipIds: ownedShipIds ?? this.ownedShipIds,
      selectedShipId: selectedShipId ?? this.selectedShipId,
      missionsProgress: missionsProgress ?? this.missionsProgress,
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
      'ownedShipIds': ownedShipIds,
      'selectedShipId': selectedShipId,
      'missionsProgress': missionsProgress.map(
        (key, value) => MapEntry(
          key,
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

    final rawOwnedShipIds = map['ownedShipIds'];
    final parsedOwnedShipIds = <String>[];

    if (rawOwnedShipIds is Iterable) {
      for (final item in rawOwnedShipIds) {
        final shipId = item.toString();

        final exists = ShipCatalog.all.any(
          (ship) => ship.id == shipId,
        );

        if (exists && !parsedOwnedShipIds.contains(shipId)) {
          parsedOwnedShipIds.add(shipId);
        }
      }
    }

    if (!parsedOwnedShipIds.contains(ShipCatalog.defaultShipId)) {
      parsedOwnedShipIds.insert(0, ShipCatalog.defaultShipId);
    }

    String parsedSelectedShipId =
        map['selectedShipId']?.toString() ?? ShipCatalog.defaultShipId;

    final selectedExists = parsedOwnedShipIds.contains(parsedSelectedShipId);

    if (!selectedExists) {
      parsedSelectedShipId = ShipCatalog.defaultShipId;
    }

    final rawMissionsProgress =
        (map['missionsProgress'] as Map<dynamic, dynamic>?) ?? {};

    final parsedMissionsProgress = <String, MissionProgress>{};

    for (final entry in rawMissionsProgress.entries) {
      final missionId = entry.key.toString();
      final valueMap = entry.value as Map<dynamic, dynamic>;

      parsedMissionsProgress[missionId] = MissionProgress.fromMap(valueMap);
    }

    return PlayerProgress(
      highestUnlockedLevel: map['highestUnlockedLevel'] ?? 1,
      coins: map['coins'] ?? 0,
      levelsProgress: parsedLevelsProgress,
      ownedShipIds: parsedOwnedShipIds,
      selectedShipId: parsedSelectedShipId,
      missionsProgress: parsedMissionsProgress,
    );
  }
}