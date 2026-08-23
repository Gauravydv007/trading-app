import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTransaction({
    required String userId,
    required String type,
    required double amount,
    required String status,
    required String reference,
  }) async {
    await _firestore.collection('transactions').add({
      'userId': userId,
      'type': type,
      'amount': amount,
      'status': status,
      'reference': reference,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TransactionModel>> transactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => TransactionModel.fromFirestore(d)).toList(),
        );
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final snap = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => TransactionModel.fromFirestore(d)).toList();
  }
}
