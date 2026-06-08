import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getUserTransactionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  // Add new transaction
  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    await _getUserTransactionsRef(uid).add(transaction.toMap());
    
    // Update user balance/totals
    final userRef = _firestore.collection('users').doc(uid);
    await _firestore.runTransaction((transactionObj) async {
      final userSnapshot = await transactionObj.get(userRef);
      if (userSnapshot.exists) {
        double currentIncome = (userSnapshot.data()?['monthlyIncome'] ?? 0.0).toDouble();
        double currentSavings = (userSnapshot.data()?['currentSavings'] ?? 0.0).toDouble();
        
        if (transaction.isIncome) {
          currentIncome += transaction.amount;
          currentSavings += transaction.amount;
        } else {
          currentSavings -= transaction.amount;
        }

        transactionObj.update(userRef, {
          'monthlyIncome': currentIncome,
          'currentSavings': currentSavings,
        });
      }
    });
  }

  // Get stream of all transactions ordered by date
  Stream<List<TransactionModel>> getTransactionsStream(String uid) {
    return _getUserTransactionsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Delete transaction
  Future<void> deleteTransaction(String uid, String transactionId) async {
    await _getUserTransactionsRef(uid).doc(transactionId).delete();
  }
}
