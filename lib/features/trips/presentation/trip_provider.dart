import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/trip_model.dart';

class TripProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  List<TripModel> _trips = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  TripProvider({required this.userId}) {
    _initStream();
  }

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initStream() {
    if (userId.isEmpty) return;
    _setLoading(true);
    _subscription?.cancel();

    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .orderBy('startDate', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _trips = snapshot.docs
            .map((doc) => TripModel.fromMap(doc.data(), doc.id))
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

  Future<bool> addTrip(String name, double budget, DateTime startDate, DateTime endDate) async {
    if (userId.isEmpty) return false;
    _setLoading(true);
    try {
      final newTrip = TripModel(
        id: '',
        name: name,
        budget: budget,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .add(newTrip.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
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
