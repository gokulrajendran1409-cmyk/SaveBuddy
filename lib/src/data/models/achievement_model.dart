enum AchievementStatus { locked, inProgress, unlocked }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String badgeIcon;
  final String category;
  final int xpReward;
  final double target;
  final bool unlocked;
  final DateTime? unlockedDate;
  final double progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeIcon,
    required this.category,
    required this.xpReward,
    required this.target,
    this.unlocked = false,
    this.unlockedDate,
    this.progress = 0,
  });

  AchievementStatus get status {
    if (unlocked) return AchievementStatus.unlocked;
    if (progress > 0) return AchievementStatus.inProgress;
    return AchievementStatus.locked;
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? badgeIcon,
    String? category,
    int? xpReward,
    double? target,
    bool? unlocked,
    DateTime? unlockedDate,
    double? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      target: target ?? this.target,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
    );
  }
}
