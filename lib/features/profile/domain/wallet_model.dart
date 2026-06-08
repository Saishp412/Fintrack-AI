import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String type; // 'Bank', 'Cash', 'Credit Card', etc.
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.createdAt,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WalletModel(
      id: documentId,
      name: map['name'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'Bank',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'balance': balance,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
