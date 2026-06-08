import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/wallet_model.dart';

class WalletProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  WalletProvider({required this.userId}) {
    _initStream();
  }

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initStream() {
    if (userId.isEmpty) return;
    _setLoading(true);
    _subscription?.cancel();

    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _wallets = snapshot.docs
            .map((doc) => WalletModel.fromMap(doc.data(), doc.id))
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

  Future<bool> addWallet(String name, String type, double initialBalance) async {
    if (userId.isEmpty) return false;
    _setLoading(true);
    try {
      final newWallet = WalletModel(
        id: '',
        name: name,
        type: type,
        balance: initialBalance,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .add(newWallet.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
