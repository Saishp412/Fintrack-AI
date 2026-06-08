import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/goal_model.dart';

class GoalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  GoalProvider({required this.userId}) {
    _initStream();
  }

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initStream() {
    if (userId.isEmpty) return;
    _setLoading(true);
    _subscription?.cancel();

    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _goals = snapshot.docs
            .map((doc) => GoalModel.fromMap(doc.data(), doc.id))
            .toList();
        _setLoading(false);
      },
      onError: (e) {
        _error = e.toString();
        _setLoading(false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<bool> addGoal(String name, double targetAmount, DateTime targetDate) async {
    if (userId.isEmpty) return false;
    _setLoading(true);
    try {
      final newGoal = GoalModel(
        id: '',
        name: name,
        targetAmount: targetAmount,
        savedAmount: 0.0,
        targetDate: targetDate,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .add(newGoal.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addFundsToGoal(String goalId, double amount) async {
    if (userId.isEmpty) return false;
    try {
      final docRef = _firestore.collection('users').doc(userId).collection('goals').doc(goalId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) throw Exception("Goal does not exist!");
        final currentSaved = (snapshot.data()?['savedAmount'] ?? 0.0).toDouble();
        transaction.update(docRef, {'savedAmount': currentSaved + amount});
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
