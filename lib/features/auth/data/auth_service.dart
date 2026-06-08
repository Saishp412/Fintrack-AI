import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get Current User Model from Firestore
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
    return null;
  }

  // Sign Up with Email and Password
  Future<UserModel?> signUpWithEmail(String fullName, String email, String password, String role) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        UserModel newUser = UserModel(
          uid: credential.user!.uid,
          fullName: fullName,
          email: email,
          createdAt: DateTime.now(),
          role: role,
        );

        // Save user to Firestore
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign up: ${e.message} (Code: ${e.code})');
      throw Exception(e.message ?? 'Signup failed');
    } catch (e) {
      print('Generic Exception during sign up: $e');
      throw Exception('Database Error: $e');
    }
    return null;
  }

  // Sign In with Email and Password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        return await getUserDetails(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
