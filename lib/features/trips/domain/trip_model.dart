import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String name;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.name,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TripModel(
      id: documentId,
      name: map['name'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'budget': budget,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
