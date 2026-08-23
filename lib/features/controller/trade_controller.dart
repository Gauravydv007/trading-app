import 'package:get/get.dart';

import 'auth_controller.dart';
import '../model/trade_model.dart';
import '../service/trade_service.dart';

class TradeController extends GetxController {
  final TradeService _tradeService = TradeService();

  final trades = <TradeModel>[].obs;
  final isLoading = false.obs;

  String? get _userId => Get.find<AuthController>().userId;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<AuthController>().currentUser, (_) => _listenToTrades());
    _listenToTrades();
  }

  void _listenToTrades() {
    final uid = _userId;
    if (uid == null) return;
    trades.bindStream(_tradeService.tradesStream(uid));
  }

  Future<void> buyCrypto({
    required String coinSymbol,
    required double usdAmount,
    required double currentPrice,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    isLoading.value = true;
    try {
      await _tradeService.buyCrypto(
        userId: uid,
        coinSymbol: coinSymbol,
        usdAmount: usdAmount,
        currentPrice: currentPrice,
      );
      Get.snackbar(
        'Success',
        'Bought $coinSymbol for \$${usdAmount.toStringAsFixed(2)}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sellCrypto({
    required String coinSymbol,
    required double coinAmount,
    required double currentPrice,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    isLoading.value = true;
    try {
      await _tradeService.sellCrypto(
        userId: uid,
        coinSymbol: coinSymbol,
        coinAmount: coinAmount,
        currentPrice: currentPrice,
      );
      final usdValue = coinAmount * currentPrice;
      Get.snackbar(
        'Success',
        'Sold $coinSymbol for \$${usdValue.toStringAsFixed(2)}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
