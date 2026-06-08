import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final double monthlyIncome;
  final String profileImageUrl;
  final double savingsGoal;
  final double currentSavings;
  final String role;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.monthlyIncome = 0.0,
    this.profileImageUrl = '',
    this.savingsGoal = 0.0,
    this.currentSavings = 0.0,
    this.role = 'professional',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      monthlyIncome: (map['monthlyIncome'] ?? 0.0).toDouble(),
      profileImageUrl: map['profileImageUrl'] ?? '',
      savingsGoal: (map['savingsGoal'] ?? 0.0).toDouble(),
      currentSavings: (map['currentSavings'] ?? 0.0).toDouble(),
      role: map['role'] ?? 'professional',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'monthlyIncome': monthlyIncome,
      'profileImageUrl': profileImageUrl,
      'savingsGoal': savingsGoal,
      'currentSavings': currentSavings,
      'role': role,
    };
  }
}
