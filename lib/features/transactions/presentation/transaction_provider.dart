import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/transaction_model.dart';
import '../data/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final String userId;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  TransactionProvider({required this.userId}) {
    _initStream();
  }

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  void _initStream() {
    if (userId.isEmpty) return;
    _setLoading(true);
    _subscription?.cancel();
    _subscription = _repository.getTransactionsStream(userId).listen(
      (data) {
        _transactions = data;
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

  Future<bool> addTransaction(double amount, String category, String type, DateTime date, String notes, {String? tripId, String? splitWith}) async {
    if (userId.isEmpty) return false;
    _setLoading(true);
    try {
      final newTx = TransactionModel(
        id: '', // Firestore generates this
        amount: amount,
        category: category,
        type: type,
        date: date,
        notes: notes,
        createdAt: DateTime.now(),
        tripId: tripId,
        splitWith: splitWith,
      );
      await _repository.addTransaction(userId, newTx);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _repository.deleteTransaction(userId, transactionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearTransactions({required bool todayOnly}) async {
    if (userId.isEmpty) return;
    _setLoading(true);
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final collection = firestore.collection('users').doc(userId).collection('transactions');
      
      QuerySnapshot query;
      if (todayOnly) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        query = await collection.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)).get();
      } else {
        query = await collection.get();
      }

      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
