enum TransactionType { deposit, withdrawal }

class PiggyTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  PiggyTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  PiggyTransaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return PiggyTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PiggyTransaction.fromMap(Map<String, dynamic> map) {
    return PiggyTransaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'deposit' ? TransactionType.deposit : TransactionType.withdrawal,
      note: map['note'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
