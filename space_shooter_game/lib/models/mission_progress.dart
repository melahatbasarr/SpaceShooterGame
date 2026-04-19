class MissionProgress {
  final String missionId;
  final int currentValue;
  final bool isCompleted;
  final bool isClaimed;

  const MissionProgress({
    required this.missionId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  MissionProgress copyWith({
    String? missionId,
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return MissionProgress(
      missionId: missionId ?? this.missionId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'missionId': missionId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
    };
  }

  factory MissionProgress.fromMap(Map<dynamic, dynamic> map) {
    return MissionProgress(
      missionId: map['missionId']?.toString() ?? '',
      currentValue: (map['currentValue'] as num?)?.toInt() ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      isClaimed: map['isClaimed'] ?? false,
    );
  }
}