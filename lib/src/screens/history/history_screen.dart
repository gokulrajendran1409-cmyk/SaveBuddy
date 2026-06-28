import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _filterType = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PiggyTransaction> _filterTransactions(TransactionProvider provider) {
    final query = _searchController.text.toLowerCase();
    return provider.transactions.where((tx) {
      if (_filterType == 'deposit' && tx.type != TransactionType.deposit) return false;
      if (_filterType == 'withdrawal' && tx.type != TransactionType.withdrawal) return false;
      if (query.isEmpty) return true;
      // Allow searching by note, type, date or amount (numeric queries)
      final amountStr = tx.amount.toString();
      final amountIntStr = tx.amount.toStringAsFixed(0);
      return tx.note.toLowerCase().contains(query) ||
          tx.type.name.toLowerCase().contains(query) ||
          DateFormat.yMMMd().format(tx.date).toLowerCase().contains(query) ||
          amountStr.contains(query) ||
          amountIntStr.contains(query);
    }).toList();
  }

  Map<String, List<PiggyTransaction>> _groupByMonth(List<PiggyTransaction> transactions) {
    final grouped = <String, List<PiggyTransaction>>{};
    for (final tx in transactions) {
      final key = DateFormat.yMMMM().format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final filtered = _filterTransactions(provider);
    final grouped = _groupByMonth(filtered);
    final monthKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('History')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search transactions',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _FilterChip(label: 'All', selected: _filterType == 'all', onTap: () => setState(() => _filterType = 'all')),
                const SizedBox(width: 10),
                _FilterChip(label: 'Deposits', selected: _filterType == 'deposit', onTap: () => setState(() => _filterType = 'deposit')),
                const SizedBox(width: 10),
                _FilterChip(label: 'Withdrawals', selected: _filterType == 'withdrawal', onTap: () => setState(() => _filterType = 'withdrawal')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text('No results found', style: Theme.of(context).textTheme.bodyLarge))
                  : ListView.builder(
                      itemCount: monthKeys.length,
                      itemBuilder: (context, index) {
                        final month = monthKeys[index];
                        final items = grouped[month] ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(month, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            ...items.map((tx) => _TimelineTransactionCard(transaction: tx)),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Text(label, style: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

class _TimelineTransactionCard extends StatelessWidget {
  final PiggyTransaction transaction;

  const _TimelineTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == TransactionType.deposit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: isDeposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, shape: BoxShape.circle)),
              Container(width: 2, height: 56, color: Theme.of(context).colorScheme.outline),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.outline)),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '₹${transaction.amount.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text('${isDeposit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}', style: TextStyle(color: isDeposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(DateFormat.yMMMMd().format(transaction.date), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
