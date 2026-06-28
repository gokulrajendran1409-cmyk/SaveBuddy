import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _StatCard(label: 'Highest Deposit', value: '₹${provider.highestDeposit.toStringAsFixed(2)}'),
            _StatCard(label: 'Highest Withdrawal', value: '₹${provider.highestWithdrawal.toStringAsFixed(2)}'),
            _StatCard(label: 'Avg Daily Savings', value: '₹${provider.averageDailySavings.toStringAsFixed(2)}'),
            _StatCard(label: 'Avg Monthly Savings', value: '₹${provider.averageMonthlySavings.toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            Text('Deposit Trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _TrendPlaceholder(label: 'Monthly deposit trend over the last 6 months'),
            const SizedBox(height: 24),
            Text('Weekly Savings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _TrendPlaceholder(label: 'Weekly savings movement over the last 7 days'),
          ],
        ),
      ),
    );
  }
}

class _TrendPlaceholder extends StatelessWidget {
  final String label;

  const _TrendPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Center(child: Icon(Icons.show_chart, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Text('Charts are temporarily shown as placeholders for Chrome compatibility.', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
