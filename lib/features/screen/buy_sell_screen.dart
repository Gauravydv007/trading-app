import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/bitcoin_chart_controller.dart';
import '../controller/trade_controller.dart';
import '../controller/wallet_controller.dart';

class BuySellScreen extends StatelessWidget {
  const BuySellScreen({super.key});

  static const _bg = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF161627);
  static const _up = Color(0xFF00E676);
  static const _down = Color(0xFFFF1744);

  @override
  Widget build(BuildContext context) {
    final chartCtrl = Get.find<BitcoinChartController>();
    final tradeCtrl = Get.find<TradeController>();
    final walletCtrl = Get.find<WalletController>();
    final amountCtrl = TextEditingController();
    final isBuy = true.obs;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'Trade',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Buy/Sell Toggle
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isBuy.value = true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isBuy.value
                                ? _up.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isBuy.value
                                ? Border.all(color: _up.withValues(alpha: 0.5))
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Buy',
                            style: TextStyle(
                              color: isBuy.value ? _up : Colors.white38,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isBuy.value = false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !isBuy.value
                                ? _down.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: !isBuy.value
                                ? Border.all(
                                    color: _down.withValues(alpha: 0.5),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sell',
                            style: TextStyle(
                              color: !isBuy.value ? _down : Colors.white38,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              final crypto = chartCtrl.selectedCrypto.value;
              final price = chartCtrl.currentPrice.value;
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
                        color: crypto.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        crypto.symbol,
                        style: TextStyle(
                          color: crypto.color,
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
                          crypto.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          crypto.symbol,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      price > 0
                          ? '\$${price.toStringAsFixed(2)}'
                          : 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy.value ? 'Amount in USD' : 'Coin Amount',
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      prefixText: isBuy.value ? '\$ ' : '',
                      prefixStyle: TextStyle(
                        color: isBuy.value ? _up : _down,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.1),
                        fontSize: 24,
                      ),
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF2A2A45)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF2A2A45)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isBuy.value ? _up : _down,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              final price = chartCtrl.currentPrice.value;
              if (amount <= 0 || price <= 0) return const SizedBox.shrink();

              final symbol = chartCtrl.selectedCrypto.value.symbol;
              if (isBuy.value) {
                final coinAmt = amount / price;
                return _previewRow(
                  'You get',
                  '${coinAmt.toStringAsFixed(8)} $symbol',
                );
              } else {
                final usdAmt = amount * price;
                return _previewRow('You get', '\$${usdAmt.toStringAsFixed(2)}');
              }
            }),

            const SizedBox(height: 12),

            Obx(() {
              final wallet = walletCtrl.wallet.value;
              if (wallet == null) return const SizedBox.shrink();
              final symbol = chartCtrl.selectedCrypto.value.symbol;
              if (isBuy.value) {
                return _previewRow(
                  'USD Balance',
                  '\$${wallet.usdBalance.toStringAsFixed(2)}',
                );
              } else {
                final coinBal = wallet.coins[symbol] ?? 0.0;
                return _previewRow(
                  '$symbol Balance',
                  coinBal.toStringAsFixed(8),
                );
              }
            }),

            const Spacer(),

            Obx(() {
              final buying = isBuy.value;
              final color = buying ? _up : _down;
              final label = buying ? 'Buy' : 'Sell';
              final symbol = chartCtrl.selectedCrypto.value.symbol;

              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: tradeCtrl.isLoading.value
                      ? null
                      : () => _executeTrade(
                          amountCtrl: amountCtrl,
                          isBuy: buying,
                          chartCtrl: chartCtrl,
                          tradeCtrl: tradeCtrl,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: tradeCtrl.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '$label $symbol',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _executeTrade({
    required TextEditingController amountCtrl,
    required bool isBuy,
    required BitcoinChartController chartCtrl,
    required TradeController tradeCtrl,
  }) {
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Invalid', 'Enter a valid amount');
      return;
    }
    final price = chartCtrl.currentPrice.value;
    if (price <= 0) {
      Get.snackbar('Error', 'Price not available');
      return;
    }

    final symbol = chartCtrl.selectedCrypto.value.symbol;

    if (isBuy) {
      tradeCtrl.buyCrypto(
        coinSymbol: symbol,
        usdAmount: amount,
        currentPrice: price,
      );
    } else {
      tradeCtrl.sellCrypto(
        coinSymbol: symbol,
        coinAmount: amount,
        currentPrice: price,
      );
    }
  }
}
