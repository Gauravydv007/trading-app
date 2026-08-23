import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistModel {
  final String watchlistId;
  final String userId;
  final String coinSymbol;

  const WatchlistModel({
    required this.watchlistId,
    required this.userId,
    required this.coinSymbol,
  });

  factory WatchlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WatchlistModel(
      watchlistId: doc.id,
      userId: data['userId'] ?? '',
      coinSymbol: data['coinSymbol'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'userId': userId, 'coinSymbol': coinSymbol};
}
