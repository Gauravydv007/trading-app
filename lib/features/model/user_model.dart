import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final double walletBalanceUSD;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.walletBalanceUSD,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      walletBalanceUSD: (data['walletBalanceUSD'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'walletBalanceUSD': walletBalanceUSD,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
