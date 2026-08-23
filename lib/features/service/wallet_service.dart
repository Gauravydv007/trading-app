import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<WalletModel?> getWallet(String userId) async {
    final doc = await _firestore.collection('wallets').doc(userId).get();
    if (!doc.exists) return null;
    return WalletModel.fromFirestore(doc);
  }

  Stream<WalletModel?> walletStream(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? WalletModel.fromFirestore(doc) : null);
  }

  Future<void> updateUsdBalance(String userId, double amount) async {
    await _firestore.collection('wallets').doc(userId).update({
      'usdBalance': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCoinBalance(
    String userId,
    String symbol,
    double amount,
  ) async {
    await _firestore.collection('wallets').doc(userId).update({
      'coins.$symbol': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<double> getPortfolioValue(
    String userId,
    Map<String, double> currentPrices,
  ) async {
    final wallet = await getWallet(userId);
    if (wallet == null) return 0.0;

    double coinValue = 0.0;
    for (final entry in wallet.coins.entries) {
      final price = currentPrices[entry.key] ?? 0.0;
      coinValue += entry.value * price;
    }

    return coinValue + wallet.usdBalance;
  }
}
