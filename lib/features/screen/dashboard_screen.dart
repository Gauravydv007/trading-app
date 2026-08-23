import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../controller/bitcoin_chart_controller.dart';
import '../controller/wallet_controller.dart';
import 'bitcoin_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _accent = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    Get.put(BitcoinChartController());
    Get.put(WalletController());

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(color: _surface),
              child: Row(
                children: [
                  const Icon(Icons.currency_bitcoin, color: _accent, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'CryptoTrader',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed('/about'),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => authCtrl.signOut(),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.white38,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            Obx(() {
              final walletCtrl = Get.find<WalletController>();
              final wallet = walletCtrl.wallet.value;
              return GestureDetector(
                onTap: () => Get.toNamed('/wallet'),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A3E), Color(0xFF0D0D1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2A2A45)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balance',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wallet != null
                                ? '\$${wallet.usdBalance.toStringAsFixed(2)}'
                                : '\$0.00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: _accent, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Deposit',
                              style: TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Chart
            const Expanded(child: BitcoinChart()),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: _surface,
                border: Border(
                  top: BorderSide(color: Color(0xFF2A2A45), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.show_chart,
                    label: 'Chart',
                    onTap: () {},
                    isActive: true,
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Wallet',
                    onTap: () => Get.toNamed('/wallet'),
                  ),
                  _NavItem(
                    icon: Icons.swap_horiz,
                    label: 'Trade',
                    onTap: () => Get.toNamed('/buysell'),
                  ),
                  _NavItem(
                    icon: Icons.history,
                    label: 'History',
                    onTap: () => Get.toNamed('/trades'),
                  ),
                  _NavItem(
                    icon: Icons.star_outline,
                    label: 'Watchlist',
                    onTap: () => Get.toNamed('/watchlist'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF00E676) : Colors.white38;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
