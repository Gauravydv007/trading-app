import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/watchlist_model.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWatchlist(String userId, String symbol) async {
    final existing = await _firestore
        .collection('watchlists')
        .where('userId', isEqualTo: userId)
        .where('coinSymbol', isEqualTo: symbol)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _firestore.collection('watchlists').add({
      'userId': userId,
      'coinSymbol': symbol,
    });
  }

  Future<void> removeFromWatchlist(String userId, String symbol) async {
    final snap = await _firestore
        .collection('watchlists')
        .where('userId', isEqualTo: userId)
        .where('coinSymbol', isEqualTo: symbol)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<WatchlistModel>> getWatchlist(String userId) {
    return _firestore
        .collection('watchlists')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WatchlistModel.fromFirestore(d)).toList(),
        );
  }
  

  Future<bool> isInWatchlist(String userId, String symbol) async {
    final snap = await _firestore
        .collection('watchlists')
        .where('userId', isEqualTo: userId)
        .where('coinSymbol', isEqualTo: symbol)
        .get();
    return snap.docs.isNotEmpty;
  }
}
