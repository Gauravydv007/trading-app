import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/trade_model.dart';

class TradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> buyCrypto({
    required String userId,
    required String coinSymbol,
    required double usdAmount,
    required double currentPrice,
  }) async {
    final coinAmount = usdAmount / currentPrice;

    final walletRef = _firestore.collection('wallets').doc(userId);

    await _firestore.runTransaction((txn) async {
      final walletSnap = await txn.get(walletRef);
      if (!walletSnap.exists) throw Exception('Wallet not found');

      final data = walletSnap.data()!;
      final usdBalance = (data['usdBalance'] as num).toDouble();
      if (usdBalance < usdAmount) throw Exception('Insufficient USD balance');

      final coins = Map<String, dynamic>.from(data['coins'] ?? {});
      final currentCoin = ((coins[coinSymbol] ?? 0) as num).toDouble();

      txn.update(walletRef, {
        'usdBalance': usdBalance - usdAmount,
        'coins.$coinSymbol': currentCoin + coinAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final tradeRef = _firestore.collection('trades').doc();
      txn.set(tradeRef, {
        'userId': userId,
        'coinSymbol': coinSymbol,
        'type': 'buy',
        'price': currentPrice,
        'quantity': coinAmount,
        'totalValue': usdAmount,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final txnRef = _firestore.collection('transactions').doc();
      txn.set(txnRef, {
        'userId': userId,
        'type': 'buy',
        'amount': usdAmount,
        'status': 'completed',
        'reference': 'Buy $coinSymbol @ \$${currentPrice.toStringAsFixed(2)}',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> sellCrypto({
    required String userId,
    required String coinSymbol,
    required double coinAmount,
    required double currentPrice,
  }) async {
    final usdValue = coinAmount * currentPrice;

    final walletRef = _firestore.collection('wallets').doc(userId);

    await _firestore.runTransaction((txn) async {
      final walletSnap = await txn.get(walletRef);
      if (!walletSnap.exists) throw Exception('Wallet not found');

      final data = walletSnap.data()!;
      final coins = Map<String, dynamic>.from(data['coins'] ?? {});
      final currentCoin = ((coins[coinSymbol] ?? 0) as num).toDouble();
      if (currentCoin < coinAmount) {
        throw Exception('Insufficient $coinSymbol balance');
      }

      final usdBalance = (data['usdBalance'] as num).toDouble();

      txn.update(walletRef, {
        'usdBalance': usdBalance + usdValue,
        'coins.$coinSymbol': currentCoin - coinAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final tradeRef = _firestore.collection('trades').doc();
      txn.set(tradeRef, {
        'userId': userId,
        'coinSymbol': coinSymbol,
        'type': 'sell',
        'price': currentPrice,
        'quantity': coinAmount,
        'totalValue': usdValue,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final txnRef = _firestore.collection('transactions').doc();
      txn.set(txnRef, {
        'userId': userId,
        'type': 'sell',
        'amount': usdValue,
        'status': 'completed',
        'reference': 'Sell $coinSymbol @ \$${currentPrice.toStringAsFixed(2)}',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<TradeModel>> tradesStream(String userId) {
    return _firestore
        .collection('trades')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => TradeModel.fromFirestore(d)).toList(),
        );
  }

  Future<List<TradeModel>> getTrades(String userId) async {
    final snap = await _firestore
        .collection('trades')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => TradeModel.fromFirestore(d)).toList();
  }
}
