import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String walletId;
  final String userId;
  final double usdBalance;
  final Map<String, double> coins;
  final DateTime updatedAt;

  const WalletModel({
    required this.walletId,
    required this.userId,
    required this.usdBalance,
    required this.coins,
    required this.updatedAt,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final coinsRaw = data['coins'] as Map<String, dynamic>? ?? {};
    return WalletModel(
      walletId: doc.id,
      userId: data['userId'] ?? '',
      usdBalance: (data['usdBalance'] ?? 0).toDouble(),
      coins: coinsRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'usdBalance': usdBalance,
    'coins': coins,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  WalletModel copyWith({double? usdBalance, Map<String, double>? coins}) {
    return WalletModel(
      walletId: walletId,
      userId: userId,
      usdBalance: usdBalance ?? this.usdBalance,
      coins: coins ?? Map.from(this.coins),
      updatedAt: DateTime.now(),
    );
  }
}
