import 'package:flutter/material.dart';

import '../data/models/achievement_model.dart';
import '../data/models/transaction_model.dart';

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [];
  final List<Achievement> _recentUnlocks = [];

  int _currentStreak = 0;
  int _longestStreak = 0;
  int _goalsCompleted = 0;
  int _highestMonthlySavings = 0;

  AchievementProvider() {
    _achievements.addAll(_buildDefinitions());
  }

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<Achievement> get recentlyUnlocked => List.unmodifiable(_recentUnlocks);
  int get totalXp => _achievements.where((achievement) => achievement.unlocked).fold(0, (sum, achievement) => sum + achievement.xpReward);
  int get unlockedCount => _achievements.where((achievement) => achievement.unlocked).length;
  int get totalAchievements => _achievements.length;
  double get completionPercentage => totalAchievements == 0 ? 0 : unlockedCount / totalAchievements;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get goalsCompleted => _goalsCompleted;
  int get highestMonthlySavings => _highestMonthlySavings;

  int get currentLevel {
    const thresholds = [0, 100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000];
    var level = 1;
    for (var i = thresholds.length - 1; i >= 0; i--) {
      if (totalXp >= thresholds[i]) {
        level = i + 1;
        break;
      }
    }
    return level.clamp(1, thresholds.length);
  }

  int get currentLevelXp {
    const thresholds = [0, 100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000];
    return thresholds[(currentLevel - 1).clamp(0, thresholds.length - 1)];
  }

  int get nextLevelXp {
    const thresholds = [0, 100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000];
    if (currentLevel >= thresholds.length) {
      return thresholds.last;
    }
    return thresholds[currentLevel];
  }

  String get rank {
    if (currentLevel >= 10) return 'Legendary Saver';
    if (currentLevel >= 8) return 'Elite Saver';
    if (currentLevel >= 5) return 'Gold Saver';
    return 'Rising Saver';
  }

  void clearRecentUnlocks() {
    _recentUnlocks.clear();
  }

  void update(List<PiggyTransaction> transactions) {
    final deposits = transactions.where((tx) => tx.type == TransactionType.deposit).toList();
    final totalSaved = deposits.fold(0.0, (sum, tx) => sum + tx.amount);
    final depositCount = deposits.length;
    final depositDays = deposits
        .map((tx) => DateTime(tx.date.year, tx.date.month, tx.date.day))
        .toSet();

    _currentStreak = _calculateCurrentStreak(depositDays);
    _longestStreak = _calculateLongestStreak(depositDays);

    final monthTotals = <String, double>{};
    for (final deposit in deposits) {
      final key = '${deposit.date.year}-${deposit.date.month.toString().padLeft(2, '0')}';
      monthTotals.update(key, (value) => value + deposit.amount, ifAbsent: () => deposit.amount);
    }
    _highestMonthlySavings = monthTotals.values.fold(0.0, (maxValue, value) => value > maxValue ? value : maxValue).toInt();
    _goalsCompleted = monthTotals.values.where((value) => value >= 10000).length;

    final weekendSaver = deposits.any((tx) => tx.date.weekday == DateTime.saturday || tx.date.weekday == DateTime.sunday);
    final earlyBirdSaver = deposits.any((tx) => tx.date.hour < 8);
    final monthlyChampion = monthTotals['${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}'] != null && monthTotals['${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}']! >= 10000;
    final superSaver = totalSaved >= 50000;
    final consistencyMaster = _longestStreak >= 30;

    final previousUnlockedIds = _achievements.where((achievement) => achievement.unlocked).map((achievement) => achievement.id).toSet();
    _recentUnlocks.clear();

    for (var index = 0; index < _achievements.length; index++) {
      final achievement = _achievements[index];
      final unlocked = _isAchievementUnlocked(
        achievement.id,
        depositCount: depositCount,
        totalSaved: totalSaved,
        currentStreak: _currentStreak,
        goalsCompleted: _goalsCompleted,
        weekendSaver: weekendSaver,
        earlyBirdSaver: earlyBirdSaver,
        monthlyChampion: monthlyChampion,
        superSaver: superSaver,
        consistencyMaster: consistencyMaster,
      );
      final progress = _calculateAchievementProgress(
        achievement.id,
        depositCount: depositCount,
        totalSaved: totalSaved,
        currentStreak: _currentStreak,
        goalsCompleted: _goalsCompleted,
      );
      final unlockedDate = unlocked
          ? achievement.unlockedDate ?? DateTime.now()
          : null;
      final updated = achievement.copyWith(
        unlocked: unlocked,
        unlockedDate: unlockedDate,
        progress: progress,
      );
      _achievements[index] = updated;
      if (unlocked && !previousUnlockedIds.contains(updated.id)) {
        _recentUnlocks.add(updated);
      }
    }

    notifyListeners();
  }

  bool _isAchievementUnlocked(
    String id, {
    required int depositCount,
    required double totalSaved,
    required int currentStreak,
    required int goalsCompleted,
    required bool weekendSaver,
    required bool earlyBirdSaver,
    required bool monthlyChampion,
    required bool superSaver,
    required bool consistencyMaster,
  }) {
    switch (id) {
      case 'first_deposit':
        return depositCount >= 1;
      case 'savings_100':
        return totalSaved >= 100;
      case 'savings_500':
        return totalSaved >= 500;
      case 'savings_1000':
        return totalSaved >= 1000;
      case 'savings_5000':
        return totalSaved >= 5000;
      case 'savings_10000':
        return totalSaved >= 10000;
      case 'savings_25000':
        return totalSaved >= 25000;
      case 'savings_50000':
        return totalSaved >= 50000;
      case 'savings_100000':
        return totalSaved >= 100000;
      case 'deposits_10':
        return depositCount >= 10;
      case 'deposits_25':
        return depositCount >= 25;
      case 'deposits_50':
        return depositCount >= 50;
      case 'deposits_100':
        return depositCount >= 100;
      case 'deposits_500':
        return depositCount >= 500;
      case 'streak_3':
        return currentStreak >= 3;
      case 'streak_7':
        return currentStreak >= 7;
      case 'streak_15':
        return currentStreak >= 15;
      case 'streak_30':
        return currentStreak >= 30;
      case 'streak_60':
        return currentStreak >= 60;
      case 'streak_100':
        return currentStreak >= 100;
      case 'goal_1':
        return goalsCompleted >= 1;
      case 'goal_3':
        return goalsCompleted >= 3;
      case 'goal_5':
        return goalsCompleted >= 5;
      case 'goal_10':
        return goalsCompleted >= 10;
      case 'weekend_saver':
        return weekendSaver;
      case 'early_bird_saver':
        return earlyBirdSaver;
      case 'monthly_champion':
        return monthlyChampion;
      case 'super_saver':
        return superSaver;
      case 'consistency_master':
        return consistencyMaster;
      default:
        return false;
    }
  }

  double _calculateAchievementProgress(
    String id, {
    required int depositCount,
    required double totalSaved,
    required int currentStreak,
    required int goalsCompleted,
  }) {
    switch (id) {
      case 'first_deposit':
        return (depositCount / 1).clamp(0, 1);
      case 'savings_100':
        return (totalSaved / 100).clamp(0, 1);
      case 'savings_500':
        return (totalSaved / 500).clamp(0, 1);
      case 'savings_1000':
        return (totalSaved / 1000).clamp(0, 1);
      case 'savings_5000':
        return (totalSaved / 5000).clamp(0, 1);
      case 'savings_10000':
        return (totalSaved / 10000).clamp(0, 1);
      case 'savings_25000':
        return (totalSaved / 25000).clamp(0, 1);
      case 'savings_50000':
        return (totalSaved / 50000).clamp(0, 1);
      case 'savings_100000':
        return (totalSaved / 100000).clamp(0, 1);
      case 'deposits_10':
        return (depositCount / 10).clamp(0, 1);
      case 'deposits_25':
        return (depositCount / 25).clamp(0, 1);
      case 'deposits_50':
        return (depositCount / 50).clamp(0, 1);
      case 'deposits_100':
        return (depositCount / 100).clamp(0, 1);
      case 'deposits_500':
        return (depositCount / 500).clamp(0, 1);
      case 'streak_3':
        return (currentStreak / 3).clamp(0, 1);
      case 'streak_7':
        return (currentStreak / 7).clamp(0, 1);
      case 'streak_15':
        return (currentStreak / 15).clamp(0, 1);
      case 'streak_30':
        return (currentStreak / 30).clamp(0, 1);
      case 'streak_60':
        return (currentStreak / 60).clamp(0, 1);
      case 'streak_100':
        return (currentStreak / 100).clamp(0, 1);
      case 'goal_1':
        return (goalsCompleted / 1).clamp(0, 1);
      case 'goal_3':
        return (goalsCompleted / 3).clamp(0, 1);
      case 'goal_5':
        return (goalsCompleted / 5).clamp(0, 1);
      case 'goal_10':
        return (goalsCompleted / 10).clamp(0, 1);
      default:
        return 0;
    }
  }

  int _calculateCurrentStreak(Set<DateTime> depositDays) {
    if (depositDays.isEmpty) return 0;
    var streak = 0;
    var currentDay = DateTime.now();
    while (depositDays.contains(DateTime(currentDay.year, currentDay.month, currentDay.day))) {
      streak += 1;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _calculateLongestStreak(Set<DateTime> depositDays) {
    if (depositDays.isEmpty) return 0;
    final sortedDates = depositDays.toList()..sort();
    var longest = 1;
    var currentStreak = 1;
    for (var i = 1; i < sortedDates.length; i++) {
      final previous = sortedDates[i - 1];
      final current = sortedDates[i];
      if (current.difference(previous).inDays == 1) {
        currentStreak += 1;
      } else if (current.difference(previous).inDays > 1) {
        longest = currentStreak > longest ? currentStreak : longest;
        currentStreak = 1;
      }
    }
    return currentStreak > longest ? currentStreak : longest;
  }

  List<Achievement> _buildDefinitions() {
    return [
      Achievement(
        id: 'first_deposit',
        title: 'First Deposit',
        description: 'Make your first savings deposit',
        badgeIcon: '🏅',
        category: 'Savings Milestones',
        xpReward: 10,
        target: 1,
      ),
      Achievement(
        id: 'savings_100',
        title: '₹100 Saved',
        description: 'Reach your first ₹100 savings milestone',
        badgeIcon: '🥈',
        category: 'Savings Milestones',
        xpReward: 20,
        target: 100,
      ),
      Achievement(
        id: 'savings_500',
        title: '₹500 Saved',
        description: 'Save a total of ₹500',
        badgeIcon: '🥉',
        category: 'Savings Milestones',
        xpReward: 30,
        target: 500,
      ),
      Achievement(
        id: 'savings_1000',
        title: '₹1,000 Saved',
        description: 'Earn your first ₹1,000 in savings',
        badgeIcon: '🏆',
        category: 'Savings Milestones',
        xpReward: 50,
        target: 1000,
      ),
      Achievement(
        id: 'savings_5000',
        title: '₹5,000 Saved',
        description: 'Save ₹5,000 total',
        badgeIcon: '🌟',
        category: 'Savings Milestones',
        xpReward: 150,
        target: 5000,
      ),
      Achievement(
        id: 'savings_10000',
        title: '₹10,000 Saved',
        description: 'Reach ₹10,000 in total savings',
        badgeIcon: '🥇',
        category: 'Savings Milestones',
        xpReward: 200,
        target: 10000,
      ),
      Achievement(
        id: 'savings_25000',
        title: '₹25,000 Saved',
        description: 'Save ₹25,000 total',
        badgeIcon: '💎',
        category: 'Savings Milestones',
        xpReward: 250,
        target: 25000,
      ),
      Achievement(
        id: 'savings_50000',
        title: '₹50,000 Saved',
        description: 'Save ₹50,000 total',
        badgeIcon: '🥂',
        category: 'Savings Milestones',
        xpReward: 300,
        target: 50000,
      ),
      Achievement(
        id: 'savings_100000',
        title: '₹1,00,000 Saved',
        description: 'Save ₹1,00,000 total',
        badgeIcon: '👑',
        category: 'Savings Milestones',
        xpReward: 500,
        target: 100000,
      ),
      Achievement(
        id: 'deposits_10',
        title: '10 Deposits',
        description: 'Complete 10 deposit transactions',
        badgeIcon: '🔷',
        category: 'Deposit Achievements',
        xpReward: 30,
        target: 10,
      ),
      Achievement(
        id: 'deposits_25',
        title: '25 Deposits',
        description: 'Complete 25 deposit transactions',
        badgeIcon: '🔶',
        category: 'Deposit Achievements',
        xpReward: 50,
        target: 25,
      ),
      Achievement(
        id: 'deposits_50',
        title: '50 Deposits',
        description: 'Complete 50 deposit transactions',
        badgeIcon: '🎖️',
        category: 'Deposit Achievements',
        xpReward: 100,
        target: 50,
      ),
      Achievement(
        id: 'deposits_100',
        title: '100 Deposits',
        description: 'Complete 100 deposits',
        badgeIcon: '🏅',
        category: 'Deposit Achievements',
        xpReward: 180,
        target: 100,
      ),
      Achievement(
        id: 'deposits_500',
        title: '500 Deposits',
        description: 'Complete 500 deposits',
        badgeIcon: '🚀',
        category: 'Deposit Achievements',
        xpReward: 400,
        target: 500,
      ),
      Achievement(
        id: 'streak_3',
        title: '3 Day Streak',
        description: 'Save for 3 consecutive days',
        badgeIcon: '🔥',
        category: 'Streak Achievements',
        xpReward: 40,
        target: 3,
      ),
      Achievement(
        id: 'streak_7',
        title: '7 Day Streak',
        description: 'Save for 7 consecutive days',
        badgeIcon: '💧',
        category: 'Streak Achievements',
        xpReward: 80,
        target: 7,
      ),
      Achievement(
        id: 'streak_15',
        title: '15 Day Streak',
        description: 'Save for 15 consecutive days',
        badgeIcon: '🌊',
        category: 'Streak Achievements',
        xpReward: 160,
        target: 15,
      ),
      Achievement(
        id: 'streak_30',
        title: '30 Day Streak',
        description: 'Save for 30 consecutive days',
        badgeIcon: '🌟',
        category: 'Streak Achievements',
        xpReward: 300,
        target: 30,
      ),
      Achievement(
        id: 'streak_60',
        title: '60 Day Streak',
        description: 'Save for 60 consecutive days',
        badgeIcon: '⚡',
        category: 'Streak Achievements',
        xpReward: 450,
        target: 60,
      ),
      Achievement(
        id: 'streak_100',
        title: '100 Day Streak',
        description: 'Save for 100 consecutive days',
        badgeIcon: '🏆',
        category: 'Streak Achievements',
        xpReward: 800,
        target: 100,
      ),
      Achievement(
        id: 'goal_1',
        title: 'First Goal',
        description: 'Complete your first savings goal',
        badgeIcon: '🎯',
        category: 'Goal Achievements',
        xpReward: 200,
        target: 1,
      ),
      Achievement(
        id: 'goal_3',
        title: '3 Goals',
        description: 'Complete 3 savings goals',
        badgeIcon: '🎯',
        category: 'Goal Achievements',
        xpReward: 250,
        target: 3,
      ),
      Achievement(
        id: 'goal_5',
        title: '5 Goals',
        description: 'Complete 5 savings goals',
        badgeIcon: '🎯',
        category: 'Goal Achievements',
        xpReward: 300,
        target: 5,
      ),
      Achievement(
        id: 'goal_10',
        title: '10 Goals',
        description: 'Complete 10 savings goals',
        badgeIcon: '🎯',
        category: 'Goal Achievements',
        xpReward: 450,
        target: 10,
      ),
      Achievement(
        id: 'weekend_saver',
        title: 'Weekend Saver',
        description: 'Save at least once on a weekend',
        badgeIcon: '🌙',
        category: 'Special Achievements',
        xpReward: 90,
        target: 1,
      ),
      Achievement(
        id: 'early_bird_saver',
        title: 'Early Bird Saver',
        description: 'Save before 8 AM',
        badgeIcon: '🌅',
        category: 'Special Achievements',
        xpReward: 90,
        target: 1,
      ),
      Achievement(
        id: 'monthly_champion',
        title: 'Monthly Champion',
        description: 'Save ₹10,000 in a month',
        badgeIcon: '🏅',
        category: 'Special Achievements',
        xpReward: 150,
        target: 1,
      ),
      Achievement(
        id: 'super_saver',
        title: 'Super Saver',
        description: 'Save ₹50,000 overall',
        badgeIcon: '🚀',
        category: 'Special Achievements',
        xpReward: 200,
        target: 1,
      ),
      Achievement(
        id: 'consistency_master',
        title: 'Consistency Master',
        description: 'Maintain a long saving streak',
        badgeIcon: '🏅',
        category: 'Special Achievements',
        xpReward: 250,
        target: 1,
      ),
    ];
  }
}
