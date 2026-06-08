import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.createdAt,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GoalModel(
      id: documentId,
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0.0).toDouble(),
      targetDate: (map['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
