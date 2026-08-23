import 'package:cloud_firestore/cloud_firestore.dart';

class TradeModel {
  final String tradeId;
  final String userId;
  final String coinSymbol;
  final String type;
  final double price;
  final double quantity;
  final double totalValue;
  final DateTime createdAt;

  const TradeModel({
    required this.tradeId,
    required this.userId,
    required this.coinSymbol,
    required this.type,
    required this.price,
    required this.quantity,
    required this.totalValue,
    required this.createdAt,
  });

  factory TradeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradeModel(
      tradeId: doc.id,
      userId: data['userId'] ?? '',
      coinSymbol: data['coinSymbol'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'coinSymbol': coinSymbol,
    'type': type,
    'price': price,
    'quantity': quantity,
    'totalValue': totalValue,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
