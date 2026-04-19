enum MissionType {
  killEnemies,
  completeLevels,
  killBosses,
  collectPowerUps,
  finishLevelWithoutMiss,
}

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int targetValue;
  final int rewardCoins;
  final int sortOrder;
  final bool isActive;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.rewardCoins,
    this.sortOrder = 0,
    this.isActive = true,
  });

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    int? targetValue,
    int? rewardCoins,
    int? sortOrder,
    bool? isActive,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'targetValue': targetValue,
      'rewardCoins': rewardCoins,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  factory Mission.fromMap(Map<dynamic, dynamic> map) {
    final typeName = map['type']?.toString() ?? MissionType.killEnemies.name;

    return Mission(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      type: MissionType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => MissionType.killEnemies,
      ),
      targetValue: (map['targetValue'] as num?)?.toInt() ?? 0,
      rewardCoins: (map['rewardCoins'] as num?)?.toInt() ?? 0,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }
}