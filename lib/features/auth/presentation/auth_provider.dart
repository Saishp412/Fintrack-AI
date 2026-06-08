import 'package:flutter/material.dart';
import '../domain/user_model.dart';
import '../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to Firebase Auth state changes
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _fetchUserDetails(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      _user = await _authService.getUserDetails(uid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String fullName, String email, String password, String role) async {
    _setLoading(true);
    try {
      _user = await _authService.signUpWithEmail(fullName, email, password, role);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null; // Clear error on new action
    notifyListeners();
  }
}
