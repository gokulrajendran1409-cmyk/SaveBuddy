import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../utils/amount_parser.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isDeposit;

  const AddTransactionScreen({super.key, this.isDeposit = true});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final List<String> _selectedEntries = [];
  int? _selectedDenomination;
  DateTime _selectedDate = DateTime.now();
  late bool _isDeposit;
  bool _saving = false;
  ParsedAmount? _parsedAmount;
  Map<int, int> _availableDenominations = {};

  static const _denominations = [1, 2, 5, 10, 20, 50, 100, 200, 500];
  static const _quickAmounts = [10, 20, 50, 100, 500, 1000];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setQuickAmount(int value) {
    _amountController.text = value.toString();
    _updateParsedAmount();
  }

  void _selectDenomination(int value) {
    setState(() => _selectedDenomination = value);
  }

  void _addSelectedDenomination(int count) {
    if (_selectedDenomination == null) return;

    if (!_isDeposit) {
      final provider = context.read<TransactionProvider>();
      final current = provider.availableDenominations[_selectedDenomination!] ?? 0;
      if (current < count) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Only $current note(s) of ₹$_selectedDenomination are available.')),
        );
        return;
      }
    }

    setState(() {
      _selectedEntries.add('${_selectedDenomination}×$count');
      _amountController.text = _selectedEntries.join(' + ');
      _selectedDenomination = null;
    });
    _updateParsedAmount();
  }

  void _clearSelection() {
    setState(() {
      _selectedEntries.clear();
      _selectedDenomination = null;
      _amountController.text = '';
      _parsedAmount = null;
    });
  }

  void _removeLastSelection() {
    if (_selectedEntries.isEmpty) {
      _clearSelection();
      return;
    }

    setState(() {
      _selectedEntries.removeLast();
      _amountController.text = _selectedEntries.isEmpty ? '' : _selectedEntries.join(' + ');
      _selectedDenomination = null;
    });
    _updateParsedAmount();
  }

  void _updateParsedAmount() {
    final parsed = AmountParser.parse(_amountController.text);
    final provider = context.read<TransactionProvider>();
    setState(() {
      _parsedAmount = parsed;
      _availableDenominations = provider.availableDenominations;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final parsed = AmountParser.parse(_amountController.text.trim());
    final amount = parsed.total;
    setState(() => _saving = true);

    try {
      final provider = context.read<TransactionProvider>();
      final note = _noteController.text.trim();
      final richNote = note.isEmpty && parsed.summary.isNotEmpty
          ? 'Breakdown: ${parsed.summary}'
          : (note.isEmpty ? '' : '$note | Breakdown: ${parsed.summary}');
      if (_isDeposit) {
        await provider.addDeposit(amount: amount, date: _selectedDate, note: richNote);
      } else {
        await provider.addWithdrawal(amount: amount, date: _selectedDate, note: richNote);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction saved successfully')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _isDeposit = widget.isDeposit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _availableDenominations = context.read<TransactionProvider>().availableDenominations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isDeposit ? 'Add Money' : 'Withdraw Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isDeposit = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDeposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                        foregroundColor: _isDeposit ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Deposit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isDeposit = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isDeposit ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.surfaceContainerHighest,
                        foregroundColor: !_isDeposit ? Theme.of(context).colorScheme.onError : Theme.of(context).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            Text('Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              readOnly: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '₹',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                hintText: 'Tap a note value',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo_outlined),
                      tooltip: 'Remove last entry',
                      onPressed: _selectedEntries.isEmpty ? null : _removeLastSelection,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: 'Clear all entries',
                      onPressed: _selectedEntries.isEmpty ? null : _clearSelection,
                    ),
                  ],
                ),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Select an amount';
                final parsed = AmountParser.parse(text);
                if (parsed.total <= 0 || parsed.parts.isEmpty) return 'Select at least one note';
                if (!_isDeposit) {
                  final provider = context.read<TransactionProvider>();
                  if (parsed.total > provider.totalBalance) {
                    return 'Not enough balance for this withdrawal';
                  }
                }
                return null;
              },
            ),
            if (_parsedAmount != null && _parsedAmount!.summary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parsed amount', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Total: ₹${_parsedAmount!.total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text('Breakdown: ${_parsedAmount!.summary}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
            if (!_isDeposit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remaining balance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Current balance: ₹${context.read<TransactionProvider>().totalBalance.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      'After this withdrawal: ₹${context.read<TransactionProvider>().getRemainingBalanceForWithdrawal(_parsedAmount?.total ?? 0).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text('Choose note value', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _denominations.map((amount) {
                final selected = _selectedDenomination == amount;
                return ElevatedButton(
                  onPressed: () => _selectDenomination(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor: selected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: Text('₹$amount'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Choose number of notes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [1, 2, 3, 4, 5, 10].map((count) {
                return ElevatedButton(
                  onPressed: _selectedDenomination == null ? null : () => _addSelectedDenomination(count),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: Text('×$count'),
                );
              }).toList(),
            ),
            if (!_isDeposit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available notes for withdrawal', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (_availableDenominations.isEmpty)
                      Text('No deposit breakdowns yet. Withdrawals will be limited by your current balance.', style: Theme.of(context).textTheme.bodyMedium)
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: _availableDenominations.entries.map((entry) {
                          final label = entry.value >= 0 ? '${entry.key} × ${entry.value}' : '${entry.key} × ${entry.value.abs()} (used)';
                          return Chip(label: Text(label));
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text('Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMMd().format(_selectedDate), style: Theme.of(context).textTheme.bodyLarge),
                    const Icon(Icons.calendar_month_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _saveTransaction,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _saving
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                      )
                    : const Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
