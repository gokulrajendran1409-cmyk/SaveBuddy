import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/achievement_model.dart';
import '../../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  var _hasShownNotifications = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final achievementProvider = context.watch<AchievementProvider>();
    if (!_hasShownNotifications && achievementProvider.recentlyUnlocked.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUnlockNotification(achievementProvider);
      });
      _hasShownNotifications = true;
    }
  }

  void _showUnlockNotification(AchievementProvider provider) {
    final unlocked = provider.recentlyUnlocked;
    if (unlocked.isEmpty) return;

    final message = unlocked.length == 1
        ? '🎉 Achievement Unlocked! ${unlocked.first.title} +${unlocked.first.xpReward} XP'
        : '🎉 ${unlocked.length} new achievements unlocked!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    provider.clearRecentUnlocks();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AchievementProvider>();
    final grouped = _groupByCategory(provider.achievements);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: _HeaderCard(provider: provider),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatisticsGrid(provider: provider),
              ),
            ),
            for (final category in grouped.keys)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ),
            for (final category in grouped.keys)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement = grouped[category]![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AchievementCard(achievement: achievement),
                      );
                    },
                    childCount: grouped[category]!.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Map<String, List<Achievement>> _groupByCategory(List<Achievement> achievements) {
    final grouped = <String, List<Achievement>>{};
    for (final achievement in achievements) {
      grouped.putIfAbsent(achievement.category, () => []).add(achievement);
    }
    return grouped;
  }
}

class _HeaderCard extends StatelessWidget {
  final AchievementProvider provider;

  const _HeaderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final level = provider.currentLevel;
    final xp = provider.totalXp;
    final currentXp = provider.currentLevelXp;
    final nextXp = provider.nextLevelXp;
    final progress = nextXp == currentXp ? 1.0 : ((xp - currentXp) / (nextXp - currentXp)).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.22), blurRadius: 30, offset: const Offset(0, 16)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.32), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level $level Saver', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                  const SizedBox(height: 6),
                  Text(provider.rank, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.72))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 900),
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                          Container(
                        height: 16,
                        width: max(0.0, MediaQuery.of(context).size.width - 40) * value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('$xp XP / $nextXp XP', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
              _StatChip(label: 'Streak', value: '${provider.currentStreak} Days'),
              _StatChip(label: 'Completed', value: '${provider.unlockedCount}/${provider.totalAchievements}'),
              _StatChip(label: 'XP Progress', value: '${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  final AchievementProvider provider;

  const _StatisticsGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _MiniStat(label: 'Total XP', value: provider.totalXp.toString()),
      _MiniStat(label: 'Achievements', value: '${provider.unlockedCount}/${provider.totalAchievements}'),
      _MiniStat(label: 'Longest Streak', value: '${provider.longestStreak}d'),
      _MiniStat(label: 'Best Month', value: '₹${provider.highestMonthlySavings}'),
      _MiniStat(label: 'Goals Completed', value: provider.goalsCompleted.toString()),
      _MiniStat(label: 'Current Rank', value: provider.rank),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats.map((stat) => SizedBox(width: (MediaQuery.of(context).size.width - 64) / 2, child: stat)).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class AchievementCard extends StatefulWidget {
  final Achievement achievement;

  const AchievementCard({required this.achievement, super.key});

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;
    final status = achievement.status;
    final isUnlocked = status == AchievementStatus.unlocked;
    final isInProgress = status == AchievementStatus.inProgress;
    final borderColor = isUnlocked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isUnlocked ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.16), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.24), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      achievement.badgeIcon,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(achievement.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(achievement.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('+${achievement.xpReward} XP', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isUnlocked) ...[
                Text('Unlocked on: ${achievement.unlockedDate != null ? '${achievement.unlockedDate!.day.toString().padLeft(2, '0')} ${_monthName(achievement.unlockedDate!)} ${achievement.unlockedDate!.year}' : 'Today'}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ] else if (isInProgress) ...[
                Text('Progress: ₹${(achievement.progress * achievement.target).toStringAsFixed(0)} / ₹${achievement.target.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 12,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(achievement.progress * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ] else ...[
                Text('Requirement: ${achievement.description}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Locked', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[date.month - 1];
  }
}
