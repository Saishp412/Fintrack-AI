import 'package:cloud_firestore/cloud_firestore.dart';

class SplitBillModel {
  final String id;
  final String title;
  final double amount;
  final String splitWith;
  final bool youOwe; // true if you owe them, false if they owe you
  final bool isSettled;
  final DateTime createdAt;

  SplitBillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.splitWith,
    required this.youOwe,
    this.isSettled = false,
    required this.createdAt,
  });

  factory SplitBillModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SplitBillModel(
      id: documentId,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      splitWith: map['splitWith'] ?? '',
      youOwe: map['youOwe'] ?? false,
      isSettled: map['isSettled'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'splitWith': splitWith,
      'youOwe': youOwe,
      'isSettled': isSettled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
