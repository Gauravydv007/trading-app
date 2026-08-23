import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/bitcoin_chart_controller.dart';
import '../controller/watchlist_controller.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _accent = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final watchCtrl = Get.find<WatchlistController>();
    final chartCtrl = Get.find<BitcoinChartController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'Watchlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: _accent),
            onPressed: () => _showAddSheet(context, watchCtrl),
          ),
        ],
      ),
      body: Obx(() {
        final items = watchCtrl.watchlist;
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_outline, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text(
                  'No coins in watchlist',
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap + to add coins',
                  style: TextStyle(color: Colors.white24, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final symbol = items[i].coinSymbol;
            final crypto = BitcoinChartController.popularCryptos
                .where((c) => c.symbol == symbol)
                .firstOrNull;

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
                      color: (crypto?.color ?? _accent).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        color: crypto?.color ?? _accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        crypto?.name ?? symbol,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (crypto != null) {
                        chartCtrl.changeCrypto(crypto);
                        Get.toNamed('/chart');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => watchCtrl.removeFromWatchlist(symbol),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white24,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddSheet(BuildContext context, WatchlistController watchCtrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161627),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add to Watchlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: BitcoinChartController.popularCryptos.length,
              itemBuilder: (_, i) {
                final crypto = BitcoinChartController.popularCryptos[i];
                return Obx(() {
                  final isWatching = watchCtrl.isWatching(crypto.symbol);
                  return GestureDetector(
                    onTap: () {
                      if (isWatching) {
                        watchCtrl.removeFromWatchlist(crypto.symbol);
                      } else {
                        watchCtrl.addToWatchlist(crypto.symbol);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isWatching
                            ? crypto.color.withValues(alpha: 0.15)
                            : const Color(0xFF0D0D1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isWatching
                              ? crypto.color.withValues(alpha: 0.6)
                              : const Color(0xFF2A2A45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: crypto.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              crypto.symbol,
                              style: TextStyle(
                                color: crypto.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crypto.symbol,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                crypto.name,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            isWatching ? Icons.star : Icons.star_outline,
                            color: isWatching
                                ? const Color(0xFFFFD700)
                                : Colors.white24,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
