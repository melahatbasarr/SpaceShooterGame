class LevelProgress {
  final int levelNumber;
  final int stars;
  final int bestScore;
  final bool isCompleted;

  const LevelProgress({
    required this.levelNumber,
    this.stars = 0,
    this.bestScore = 0,
    this.isCompleted = false,
  });

  LevelProgress copyWith({
    int? levelNumber,
    int? stars,
    int? bestScore,
    bool? isCompleted,
  }) {
    return LevelProgress(
      levelNumber: levelNumber ?? this.levelNumber,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelNumber': levelNumber,
      'stars': stars,
      'bestScore': bestScore,
      'isCompleted': isCompleted,
    };
  }

  factory LevelProgress.fromMap(Map<dynamic, dynamic> map) {
    return LevelProgress(
      levelNumber: map['levelNumber'] ?? 1,
      stars: map['stars'] ?? 0,
      bestScore: map['bestScore'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}