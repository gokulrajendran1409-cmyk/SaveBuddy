import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _ReportCard(
              title: 'Daily Report',
              subtitle: 'Net snapshot for today',
              totalDeposited: provider.totalDeposited,
              totalWithdrawn: provider.totalWithdrawn,
              netSavings: provider.totalBalance,
            ),
            _ReportCard(
              title: 'Weekly Report',
              subtitle: 'Summary for the last 7 days',
              totalDeposited: provider.totalDeposited,
              totalWithdrawn: provider.totalWithdrawn,
              netSavings: provider.totalBalance,
            ),
            _ReportCard(
              title: 'Monthly Report',
              subtitle: 'Summary for this month',
              totalDeposited: provider.totalDeposited,
              totalWithdrawn: provider.totalWithdrawn,
              netSavings: provider.totalBalance,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double totalDeposited;
  final double totalWithdrawn;
  final double netSavings;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.totalDeposited,
    required this.totalWithdrawn,
    required this.netSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Divider(color: Theme.of(context).colorScheme.outline, height: 24, thickness: 1),
            _ReportRow(label: 'Total Deposited', value: '₹${totalDeposited.toStringAsFixed(2)}'),
            _ReportRow(label: 'Total Withdrawn', value: '₹${totalWithdrawn.toStringAsFixed(2)}'),
            _ReportRow(label: 'Net Savings', value: '₹${netSavings.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
