import '../models/mission.dart';

class MissionDefinitions {
  MissionDefinitions._();

  static const List<Mission> all = [
    Mission(
      id: 'first_blood',
      title: 'First Blood',
      description: 'Destroy 10 enemies.',
      type: MissionType.killEnemies,
      targetValue: 10,
      rewardCoins: 50,
      sortOrder: 1,
    ),
    Mission(
      id: 'survivor',
      title: 'Survivor',
      description: 'Complete 3 levels.',
      type: MissionType.completeLevels,
      targetValue: 3,
      rewardCoins: 75,
      sortOrder: 2,
    ),
    Mission(
      id: 'hunter',
      title: 'Hunter',
      description: 'Destroy 25 enemies.',
      type: MissionType.killEnemies,
      targetValue: 25,
      rewardCoins: 100,
      sortOrder: 3,
    ),
    Mission(
      id: 'collector',
      title: 'Collector',
      description: 'Collect 5 power-ups.',
      type: MissionType.collectPowerUps,
      targetValue: 5,
      rewardCoins: 80,
      sortOrder: 4,
    ),
    Mission(
      id: 'boss_slayer',
      title: 'Boss Slayer',
      description: 'Defeat 1 boss.',
      type: MissionType.killBosses,
      targetValue: 1,
      rewardCoins: 150,
      sortOrder: 5,
    ),
    Mission(
      id: 'perfect_run',
      title: 'Perfect Run',
      description: 'Finish 1 level without missing any enemy.',
      type: MissionType.finishLevelWithoutMiss,
      targetValue: 1,
      rewardCoins: 120,
      sortOrder: 6,
    ),
  ];

  static Mission? getById(String missionId) {
    for (final mission in all) {
      if (mission.id == missionId) {
        return mission;
      }
    }

    return null;
  }
}