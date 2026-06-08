import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String notes;
  final DateTime createdAt;
  final String? tripId;
  final String? splitWith;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.notes = '',
    required this.createdAt,
    this.tripId,
    this.splitWith,
  });

  bool get isIncome => type == 'income';

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      type: map['type'] ?? 'expense',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tripId: map['tripId'],
      splitWith: map['splitWith'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'type': type,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (tripId != null) 'tripId': tripId,
      if (splitWith != null) 'splitWith': splitWith,
    };
  }
}
