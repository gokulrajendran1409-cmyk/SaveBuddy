import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../history/history_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final now = DateTime.now();
    final formattedDate = DateFormat.yMMMMd().format(now);
    final progress = (provider.totalBalance / 10000).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Save Today, Smile Tomorrow', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(formattedDate, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.28),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Savings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.86))),
                                const SizedBox(height: 10),
                                Text('₹${provider.totalBalance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 40, color: Theme.of(context).colorScheme.onPrimary)),
                              ],
                            ),
                          ),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Icon(Icons.savings, color: Theme.of(context).colorScheme.onPrimary, size: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Goal progress', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.86))),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 14,
                          color: Theme.of(context).colorScheme.secondary,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('${(progress * 100).toStringAsFixed(0)}% completed', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    _QuickActionCard(
                      title: 'Add Money',
                      icon: Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen(isDeposit: true))),
                    ),
                    const SizedBox(width: 12),
                    _QuickActionCard(
                      title: 'Withdraw',
                      icon: Icons.arrow_upward_outlined,
                      color: Theme.of(context).colorScheme.error,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen(isDeposit: false))),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _QuickActionCard(
                      title: 'History',
                      icon: Icons.history,
                      color: Theme.of(context).colorScheme.secondary,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    ),
                    const SizedBox(width: 12),
                    _QuickActionCard(
                      title: 'Reports',
                      icon: Icons.insert_chart_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen())),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent transactions', style: Theme.of(context).textTheme.titleMedium),
                    Text('See all', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = provider.transactions.length > index ? provider.transactions[index] : null;
                  if (tx == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tx.type == TransactionType.deposit ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              tx.type == TransactionType.deposit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: tx.type == TransactionType.deposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.note.isEmpty ? 'Savings' : tx.note, style: Theme.of(context).textTheme.bodyLarge),
                                const SizedBox(height: 6),
                                Text(DateFormat.yMMMd().format(tx.date), style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          Text(
                            '${tx.type == TransactionType.deposit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tx.type == TransactionType.deposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: provider.transactions.length > 4 ? 4 : provider.transactions.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 116,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
