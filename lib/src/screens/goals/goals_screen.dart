import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const goalAmount = 10000.0;
    const goalMonth = 5; // May
    final provider = context.watch<TransactionProvider>();
    final maySavings = provider.transactions
        .where((tx) => tx.date.month == goalMonth)
        .fold(0.0, (double sum, tx) => sum + (tx.type == TransactionType.deposit ? tx.amount : -tx.amount));
    final progress = (maySavings / goalAmount).clamp(0.0, 1.0);
    final progressText = maySavings <= 0 ? 'No savings yet for May' : '₹${maySavings.toStringAsFixed(2)} saved in May';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Savings Goals')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goal: ₹10000', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Text('Deadline: 31 Dec 2026', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 14,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('${(progress * 100).toStringAsFixed(0)}% completed', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text(progressText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Achievements', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _BadgeCard(title: 'First ₹1000 Saved', completed: maySavings >= 1000),
                _BadgeCard(title: 'First ₹5000 Saved', completed: maySavings >= 5000),
                _BadgeCard(title: 'First ₹10000 Saved', completed: maySavings >= 10000),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final bool completed;

  const _BadgeCard({required this.title, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      width: 160,
      decoration: BoxDecoration(
        color: completed ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: completed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          Icon(completed ? Icons.emoji_events : Icons.lock_outline, color: completed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
