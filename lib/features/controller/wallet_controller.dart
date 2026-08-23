import 'package:get/get.dart';

import 'auth_controller.dart';
import 'bitcoin_chart_controller.dart';
import '../model/wallet_model.dart';
import '../service/wallet_service.dart';

class WalletController extends GetxController {
  final WalletService _walletService = WalletService();

  final Rxn<WalletModel> wallet = Rxn<WalletModel>();
  final isLoading = true.obs;
  final portfolioValue = 0.0.obs;
  final totalInvested = 0.0.obs;
  final profitLoss = 0.0.obs;

  String? get _userId => Get.find<AuthController>().userId;

  @override
  void onInit() {
    super.onInit();
    _listenToWallet();
  }

  void _listenToWallet() {
    final uid = _userId;
    if (uid == null) return;

    wallet.bindStream(_walletService.walletStream(uid));
    ever(wallet, (_) => _calculatePortfolio());
    isLoading.value = false;
  }

  void _calculatePortfolio() {
    final w = wallet.value;
    if (w == null) return;

    final chartCtrl = Get.find<BitcoinChartController>();
    final currentPrice = chartCtrl.currentPrice.value;
    final selectedSymbol = chartCtrl.selectedCrypto.value.symbol;

    double coinValue = 0.0;
    for (final entry in w.coins.entries) {
      if (entry.key == selectedSymbol) {
        coinValue += entry.value * currentPrice;
      } else {
        coinValue += entry.value * _getCachedPrice(entry.key);
      }
    }

    portfolioValue.value = coinValue + w.usdBalance;
  }

  final Map<String, double> _priceCache = {};

  double _getCachedPrice(String symbol) => _priceCache[symbol] ?? 0.0;

  void updatePriceCache(String symbol, double price) {
    _priceCache[symbol] = price;
    _calculatePortfolio();
  }

  @override
  Future<void> refresh() async {
    final uid = _userId;
    if (uid == null) return;
    wallet.value = await _walletService.getWallet(uid);
    _calculatePortfolio();
  }
}
