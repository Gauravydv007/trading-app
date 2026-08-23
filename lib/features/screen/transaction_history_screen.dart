import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/transaction_controller.dart';
import '../model/transaction_model.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _accent = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final txnCtrl = Get.find<TransactionController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        final txns = txnCtrl.transactions;
        if (txns.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _buildTxnItem(txns[i]),
        );
      }),
    );
  }

  Widget _buildTxnItem(TransactionModel txn) {
    final dateStr = DateFormat('MMM d, yyyy  HH:mm').format(txn.createdAt);
    final config = _getTypeConfig(txn.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A45)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(config.icon, color: config.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.label,
                  style: TextStyle(
                    color: config.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.reference.isNotEmpty ? txn.reference : txn.status,
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${config.sign}\$${txn.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: config.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(txn.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  txn.status,
                  style: TextStyle(
                    color: _getStatusColor(txn.status),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig(String type) {
    switch (type) {
      case 'deposit':
        return _TypeConfig(
          label: 'Deposit',
          icon: Icons.add_circle_outline,
          color: _accent,
          sign: '+',
        );
      case 'withdraw':
        return _TypeConfig(
          label: 'Withdrawal',
          icon: Icons.remove_circle_outline,
          color: const Color(0xFFFF9800),
          sign: '-',
        );
      case 'buy':
        return _TypeConfig(
          label: 'Buy',
          icon: Icons.shopping_cart_outlined,
          color: const Color(0xFF2196F3),
          sign: '-',
        );
      case 'sell':
        return _TypeConfig(
          label: 'Sell',
          icon: Icons.sell_outlined,
          color: const Color(0xFF9C27B0),
          sign: '+',
        );
      default:
        return _TypeConfig(
          label: type,
          icon: Icons.swap_horiz,
          color: Colors.white38,
          sign: '',
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return _accent;
      case 'pending':
        return const Color(0xFFFF9800);
      case 'failed':
        return const Color(0xFFFF1744);
      default:
        return Colors.white38;
    }
  }
}

class _TypeConfig {
  final String label;
  final IconData icon;
  final Color color;
  final String sign;

  const _TypeConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.sign,
  });
}
