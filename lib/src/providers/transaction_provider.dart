import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/transaction_model.dart';
import '../data/services/transaction_storage.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionStorage _storage = TransactionStorage.instance;
  final List<PiggyTransaction> _transactions = [];
  bool _isReady = false;

  bool get isReady => _isReady;
  List<PiggyTransaction> get transactions => List.unmodifiable(_transactions);

  double get totalBalance {
    return _transactions.fold(0.0, (sum, tx) {
      return sum + (tx.type == TransactionType.deposit ? tx.amount : -tx.amount);
    });
  }

  Map<int, int> get availableDenominations {
    final available = <int, int>{};
    final deposits = _transactions.where((tx) => tx.type == TransactionType.deposit).toList();
    final withdrawals = _transactions.where((tx) => tx.type == TransactionType.withdrawal).toList();

    for (final tx in deposits) {
      final breakdown = tx.note.contains('Breakdown:') ? tx.note.split('Breakdown:').last.trim() : '';
      if (breakdown.isEmpty) {
        final count = (tx.amount / 10).round();
        available.update(10, (value) => value + count, ifAbsent: () => count);
        continue;
      }

      final matches = RegExp(r'(\d+)\s*×\s*(\d+)').allMatches(breakdown);
      for (final match in matches) {
        final denomination = int.tryParse(match.group(1) ?? '') ?? 0;
        final count = int.tryParse(match.group(2) ?? '') ?? 0;
        if (denomination <= 0 || count <= 0) continue;
        available.update(denomination, (value) => value + count, ifAbsent: () => count);
      }
    }

    for (final tx in withdrawals) {
      final breakdown = tx.note.contains('Breakdown:') ? tx.note.split('Breakdown:').last.trim() : '';
      if (breakdown.isEmpty) {
        final count = (tx.amount / 10).round();
        available.update(10, (value) => value - count, ifAbsent: () => -count);
        continue;
      }

      final matches = RegExp(r'(\d+)\s*×\s*(\d+)').allMatches(breakdown);
      for (final match in matches) {
        final denomination = int.tryParse(match.group(1) ?? '') ?? 0;
        final count = int.tryParse(match.group(2) ?? '') ?? 0;
        if (denomination <= 0 || count <= 0) continue;
        available.update(denomination, (value) => value - count, ifAbsent: () => -count);
      }
    }

    return available;
  }

  double get totalDeposited {
    return _transactions.where((tx) => tx.type == TransactionType.deposit).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getRemainingBalanceForWithdrawal(double withdrawalAmount) {
    return totalBalance - withdrawalAmount;
  }

  double get totalWithdrawn {
    return _transactions.where((tx) => tx.type == TransactionType.withdrawal).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  int get transactionCount => _transactions.length;

  double get highestDeposit {
    final deposits = _transactions.where((tx) => tx.type == TransactionType.deposit);
    if (deposits.isEmpty) return 0.0;
    return deposits.map((tx) => tx.amount).reduce((value, element) => value > element ? value : element);
  }

  double get highestWithdrawal {
    final withdrawals = _transactions.where((tx) => tx.type == TransactionType.withdrawal);
    if (withdrawals.isEmpty) return 0.0;
    return withdrawals.map((tx) => tx.amount).reduce((value, element) => value > element ? value : element);
  }

  double get averageDailySavings {
    final map = <String, double>{};
    for (final tx in _transactions) {
      final key = tx.date.toIso8601String().split('T').first;
      map.update(key, (value) => value + (tx.type == TransactionType.deposit ? tx.amount : -tx.amount), ifAbsent: () => tx.type == TransactionType.deposit ? tx.amount : -tx.amount);
    }
    if (map.isEmpty) return 0.0;
    return map.values.reduce((a, b) => a + b) / map.length;
  }

  double get averageMonthlySavings {
    final map = <String, double>{};
    for (final tx in _transactions) {
      final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      map.update(key, (value) => value + (tx.type == TransactionType.deposit ? tx.amount : -tx.amount), ifAbsent: () => tx.type == TransactionType.deposit ? tx.amount : -tx.amount);
    }
    if (map.isEmpty) return 0.0;
    return map.values.reduce((a, b) => a + b) / map.length;
  }

  Future<void> loadTransactions() async {
    final transactions = await _storage.fetchTransactions();
    _transactions.clear();
    _transactions.addAll(transactions);
    _isReady = true;
    notifyListeners();
  }

  Future<void> addDeposit({
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final tx = PiggyTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.deposit,
      note: note,
      date: date,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);
    await _storage.addTransaction(tx);
    notifyListeners();
  }

  Future<void> addWithdrawal({
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    if (amount > totalBalance) {
      throw Exception('Insufficient balance');
    }
    final tx = PiggyTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.withdrawal,
      note: note,
      date: date,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);
    await _storage.addTransaction(tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await _storage.deleteTransaction(id);
    notifyListeners();
  }

  Future<void> resetTransactions() async {
    _transactions.clear();
    await _storage.clearAll();
    notifyListeners();
  }
}
