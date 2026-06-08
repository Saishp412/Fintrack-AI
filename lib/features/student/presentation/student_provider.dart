import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/split_bill_model.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  List<SplitBillModel> _splitBills = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  StudentProvider({required this.userId}) {
    _initStream();
  }

  List<SplitBillModel> get splitBills => _splitBills;
  List<SplitBillModel> get activeBills => _splitBills.where((b) => !b.isSettled).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalOwedToYou => activeBills.where((b) => !b.youOwe).fold(0, (sum, b) => sum + b.amount);
  double get totalYouOwe => activeBills.where((b) => b.youOwe).fold(0, (sum, b) => sum + b.amount);

  double calculateDailySafeSpend(double income, double expenses) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysLeft = daysInMonth - now.day + 1;
    
    final remainingFunds = income - expenses;
    if (remainingFunds <= 0 || daysLeft <= 0) return 0.0;
    
    return remainingFunds / daysLeft;
  }

  void _initStream() {
    if (userId.isEmpty) return;
    _setLoading(true);
    _subscription?.cancel();

    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('split_bills')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _splitBills = snapshot.docs
            .map((doc) => SplitBillModel.fromMap(doc.data(), doc.id))
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

  Future<bool> addSplitBill(String title, double amount, String splitWith, bool youOwe) async {
    if (userId.isEmpty) return false;
    _setLoading(true);
    try {
      final newBill = SplitBillModel(
        id: '',
        title: title,
        amount: amount,
        splitWith: splitWith,
        youOwe: youOwe,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('split_bills')
          .add(newBill.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> markAsSettled(String billId, bool isSettled) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('split_bills')
          .doc(billId)
          .update({'isSettled': isSettled});
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('split_bills')
          .doc(billId)
          .delete();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
