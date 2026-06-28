import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

class TransactionStorage {
  static final TransactionStorage instance = TransactionStorage._internal();
  static Database? _database;

  TransactionStorage._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'piggy_bank.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            note TEXT,
            date TEXT NOT NULL,
            createdAt TEXT NOT NULL
          );
        ''');
      },
    );
  }

  Future<List<PiggyTransaction>> fetchTransactions() async {
    if (kIsWeb) {
      return _fetchTransactionsFromPreferences();
    }

    final db = await database;
    final rows = await db.query(
      'transactions',
      orderBy: 'date DESC, createdAt DESC',
    );
    return rows.map((row) => PiggyTransaction.fromMap(row)).toList();
  }

  Future<void> addTransaction(PiggyTransaction transaction) async {
    if (kIsWeb) {
      final transactions = await _fetchTransactionsFromPreferences();
      final updated = [transaction, ...transactions];
      await _saveTransactionsToPreferences(updated);
      return;
    }

    final db = await database;
    await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTransaction(String id) async {
    if (kIsWeb) {
      final transactions = await _fetchTransactionsFromPreferences();
      final updated = transactions.where((tx) => tx.id != id).toList();
      await _saveTransactionsToPreferences(updated);
      return;
    }

    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webStorageKey);
      return;
    }

    final db = await database;
    await db.delete('transactions');
  }

  static const String _webStorageKey = 'piggy_bank_transactions';

  Future<List<PiggyTransaction>> _fetchTransactionsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_webStorageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => PiggyTransaction.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList()
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Future<void> _saveTransactionsToPreferences(List<PiggyTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(transactions.map((tx) => tx.toMap()).toList());
    await prefs.setString(_webStorageKey, jsonString);
  }
}
