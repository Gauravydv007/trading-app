import 'package:get/get.dart';

import 'auth_controller.dart';
import '../model/watchlist_model.dart';
import '../service/watchlist_service.dart';

class WatchlistController extends GetxController {
  final WatchlistService _watchlistService = WatchlistService();

  final watchlist = <WatchlistModel>[].obs;

  String? get _userId => Get.find<AuthController>().userId;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<AuthController>().currentUser, (_) => _listenToWatchlist());
    _listenToWatchlist();
  }

  void _listenToWatchlist() {
    final uid = _userId;
    if (uid == null) return;
    watchlist.bindStream(_watchlistService.getWatchlist(uid));
  }

  Future<void> addToWatchlist(String symbol) async {
    final uid = _userId;
    if (uid == null) return;
    await _watchlistService.addToWatchlist(uid, symbol);
    Get.snackbar('Added', '$symbol added to watchlist');
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final uid = _userId;
    if (uid == null) return;
    await _watchlistService.removeFromWatchlist(uid, symbol);
    Get.snackbar('Removed', '$symbol removed from watchlist');
  }

  bool isWatching(String symbol) {
    return watchlist.any((w) => w.coinSymbol == symbol);
  }
}
