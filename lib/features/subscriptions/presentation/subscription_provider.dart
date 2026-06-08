import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/subscription_model.dart';

class SubscriptionProvider with ChangeNotifier {
  List<SubscriptionModel> _subscriptions = [];
  List<SubscriptionModel> get subscriptions => _subscriptions;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SubscriptionProvider() {
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .get();

      _subscriptions = snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching subscriptions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .add(sub.toMap());
      
      _subscriptions.add(SubscriptionModel(
        id: docRef.id,
        name: sub.name,
        amount: sub.amount,
        billingDay: sub.billingDay,
        category: sub.category,
      ));
      notifyListeners();
    } catch (e) {
      print('Error adding subscription: $e');
    }
  }

  Future<void> deleteSubscription(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .doc(id)
          .delete();
      
      _subscriptions.removeWhere((sub) => sub.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting subscription: $e');
    }
  }
}
