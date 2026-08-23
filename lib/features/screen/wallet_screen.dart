import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _accent = Color(0xFF00E676);
  static const _red = Color(0xFFFF1744);

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        final wallet = walletCtrl.wallet.value;
        if (wallet == null) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        return RefreshIndicator(
          color: _accent,
          onRefresh: () => walletCtrl.refresh(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A3E), Color(0xFF161627)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A2A45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Portfolio Value',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        '\$${walletCtrl.portfolioValue.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final pl = walletCtrl.profitLoss.value;
                      final isProfit = pl >= 0;
                      return Row(
                        children: [
                          Icon(
                            isProfit ? Icons.trending_up : Icons.trending_down,
                            color: isProfit ? _accent : _red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isProfit ? '+' : ''}\$${pl.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isProfit ? _accent : _red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'P&L',
                            style: TextStyle(
                              color: (isProfit ? _accent : _red).withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // USD Balance
              _buildBalanceItem(
                icon: Icons.attach_money,
                label: 'USD Balance',
                value: '\$${wallet.usdBalance.toStringAsFixed(2)}',
                color: _accent,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add,
                      label: 'Deposit',
                      onTap: () => Get.toNamed('/deposit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.swap_horiz,
                      label: 'Trade',
                      onTap: () => Get.toNamed('/buysell'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Coin Balances',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              ...wallet.coins.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildBalanceItem(
                    icon: Icons.currency_bitcoin,
                    label: entry.key,
                    value: entry.value.toStringAsFixed(8),
                    color: _getCoinColor(entry.key),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _accent, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: _accent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoinColor(String symbol) {
    switch (symbol) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'SOL':
        return const Color(0xFF9945FF);
      case 'BNB':
        return const Color(0xFFF3BA2F);
      case 'XRP':
        return const Color(0xFF00AAE4);
      case 'DOGE':
        return const Color(0xFFC2A633);
      case 'ADA':
        return const Color(0xFF0033AD);
      case 'AVAX':
        return const Color(0xFFE84142);
      case 'LINK':
        return const Color(0xFF2A5ADA);
      case 'LTC':
        return const Color(0xFFA6A9AA);
      default:
        return const Color(0xFF00E676);
    }
  }
}
