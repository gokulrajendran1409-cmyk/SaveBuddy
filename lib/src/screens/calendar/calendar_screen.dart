import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  List<PiggyTransaction> _transactionsForDate(TransactionProvider provider) {
    return provider.transactions.where((tx) {
      return tx.date.year == _selectedDate.year && tx.date.month == _selectedDate.month && tx.date.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final dailyTransactions = _transactionsForDate(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                title: Text(DateFormat.yMMMMd().format(_selectedDate)),
                subtitle: const Text('Tap to change date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: dailyTransactions.isEmpty
                  ? const Center(child: Text('No transactions for selected date'))
                  : ListView.separated(
                      itemCount: dailyTransactions.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = dailyTransactions[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tx.type == TransactionType.deposit ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer,
                              child: Icon(tx.type == TransactionType.deposit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: tx.type == TransactionType.deposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error),
                            ),
                            title: Text('₹${tx.amount.toStringAsFixed(2)}'),
                            subtitle: Text(tx.note.isEmpty ? 'No note' : tx.note),
                            trailing: Text(DateFormat.Hm().format(tx.createdAt)),
                          ),
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
