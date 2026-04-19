import '../data/mission_definitions.dart';
import '../models/mission.dart';
import '../models/mission_progress.dart';
import 'progress_service.dart';

enum MissionClaimResult {
  success,
  missionNotFound,
  notCompleted,
  alreadyClaimed,
}

class MissionWithProgress {
  final Mission mission;
  final MissionProgress progress;

  const MissionWithProgress({
    required this.mission,
    required this.progress,
  });

  double get progressRatio {
    if (mission.targetValue <= 0) {
      return 0;
    }

    return (progress.currentValue / mission.targetValue).clamp(0.0, 1.0);
  }
}

class MissionService {
  MissionService._();

  static final MissionService instance = MissionService._();

  List<Mission> getAllMissions() {
    final missions = MissionDefinitions.all
        .where((mission) => mission.isActive)
        .toList();

    missions.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return missions;
  }

  MissionProgress getMissionProgress(String missionId) {
    final progress = ProgressService.instance.loadProgress();

    return progress.missionsProgress[missionId] ??
        MissionProgress(
          missionId: missionId,
        );
  }

  List<MissionWithProgress> getAllMissionsWithProgress() {
    final missions = getAllMissions();

    return missions.map((mission) {
      return MissionWithProgress(
        mission: mission,
        progress: getMissionProgress(mission.id),
      );
    }).toList();
  }

  int getClaimableMissionCount() {
    final items = getAllMissionsWithProgress();

    return items.where((item) {
      return item.progress.isCompleted && !item.progress.isClaimed;
    }).length;
  }

  Future<List<Mission>> addProgress({
    required MissionType type,
    int amount = 1,
  }) async {
    final progress = ProgressService.instance.loadProgress();
    final updatedMissionsProgress =
        Map<String, MissionProgress>.from(progress.missionsProgress);

    final newlyCompletedMissions = <Mission>[];

    for (final mission in getAllMissions()) {
      if (mission.type != type) {
        continue;
      }

      final currentMissionProgress =
          updatedMissionsProgress[mission.id] ??
              MissionProgress(missionId: mission.id);

      if (currentMissionProgress.isClaimed) {
        continue;
      }

      final updatedValue =
          (currentMissionProgress.currentValue + amount).clamp(
            0,
            mission.targetValue,
          );

      final bool wasCompleted = currentMissionProgress.isCompleted;
      final bool isNowCompleted = updatedValue >= mission.targetValue;

      updatedMissionsProgress[mission.id] = currentMissionProgress.copyWith(
        currentValue: updatedValue,
        isCompleted: isNowCompleted,
      );

      if (!wasCompleted && isNowCompleted) {
        newlyCompletedMissions.add(mission);
      }
    }

    final updatedPlayerProgress = progress.copyWith(
      missionsProgress: updatedMissionsProgress,
    );

    await ProgressService.instance.saveProgress(updatedPlayerProgress);

    return newlyCompletedMissions;
  }

  Future<List<Mission>> registerLevelCompleted({
    required bool withoutMiss,
  }) async {
    final completedMissions = <Mission>[];

    final levelCompleteMissions = await addProgress(
      type: MissionType.completeLevels,
      amount: 1,
    );

    completedMissions.addAll(levelCompleteMissions);

    if (withoutMiss) {
      final perfectRunMissions = await addProgress(
        type: MissionType.finishLevelWithoutMiss,
        amount: 1,
      );

      completedMissions.addAll(perfectRunMissions);
    }

    return completedMissions;
  }

  Future<MissionClaimResult> claimReward(String missionId) async {
    final mission = MissionDefinitions.getById(missionId);

    if (mission == null) {
      return MissionClaimResult.missionNotFound;
    }

    final progress = ProgressService.instance.loadProgress();
    final currentMissionProgress =
        progress.missionsProgress[missionId] ??
            MissionProgress(missionId: missionId);

    if (!currentMissionProgress.isCompleted) {
      return MissionClaimResult.notCompleted;
    }

    if (currentMissionProgress.isClaimed) {
      return MissionClaimResult.alreadyClaimed;
    }

    final updatedMissionsProgress =
        Map<String, MissionProgress>.from(progress.missionsProgress);

    updatedMissionsProgress[missionId] = currentMissionProgress.copyWith(
      isClaimed: true,
    );

    final updatedPlayerProgress = progress.copyWith(
      coins: progress.coins + mission.rewardCoins,
      missionsProgress: updatedMissionsProgress,
    );

    await ProgressService.instance.saveProgress(updatedPlayerProgress);

    return MissionClaimResult.success;
  }
}