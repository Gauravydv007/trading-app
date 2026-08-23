import 'package:cloud_firestore/cloud_firestore.dart';

class StripeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static void init() {

  }

 
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

 
    await Future.delayed(const Duration(seconds: 1));

    final demoPaymentIntentId =
        'demo_pi_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'clientSecret': 'demo_client_secret_$demoPaymentIntentId',
      'paymentIntentId': demoPaymentIntentId,
      'amount': amount,
      'currency': currency,
    };
  }

  Future<bool> openStripePaymentSheet({required String clientSecret}) async {
    if (clientSecret.isEmpty) {
      throw ArgumentError('Client secret cannot be empty.');
    }


    await Future.delayed(const Duration(seconds: 2));

    return true;
  }

  Future<void> confirmDeposit({
    required String userId,
    required double amount,
    required String paymentIntentId,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    if (paymentIntentId.isEmpty) {
      throw ArgumentError('Payment intent ID cannot be empty.');
    }

    final walletRef = _firestore.collection('wallets').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final walletSnapshot = await transaction.get(walletRef);

      if (!walletSnapshot.exists) {
        throw Exception('Wallet not found.');
      }

      final data = walletSnapshot.data();

      if (data == null) {
        throw Exception('Wallet data is unavailable.');
      }

      final currentBalance = (data['usdBalance'] as num?)?.toDouble() ?? 0.0;

      final newBalance = currentBalance + amount;

      transaction.update(walletRef, {
        'usdBalance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _firestore.collection('transactions').add({
      'userId': userId,
      'type': 'deposit',
      'amount': amount,
      'status': 'completed',
      'reference': paymentIntentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
