import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';

import '../model/bitcoin_trade_model.dart';
import '../service/bitcoin_websocket_service.dart';

class CryptoOption {
  final String symbol;
  final String name;
  final String wsSymbol;
  final Color color;

  const CryptoOption({
    required this.symbol,
    required this.name,
    required this.wsSymbol,
    required this.color,
  });
}

class BitcoinChartController extends GetxController {
  final _service = BitcoinWebSocketService();

  final List<BitcoinTrade> _allTrades = [];
  static const _maxStoredTrades = 10000;

  final currentPrice = 0.0.obs;
  final priceChange = 0.0.obs;
  final priceChangePercent = 0.0.obs;
  final isPriceUp = true.obs;
  final selectedFilter = '1M'.obs;
  final connectionStatus = 'Connecting'.obs;
  final chartSpots = <FlSpot>[].obs;

  static const filters = ['1M', '5M', '15M', '1H', '1D'];

  static const popularCryptos = [
    CryptoOption(
      symbol: 'BTC',
      name: 'Bitcoin',
      wsSymbol: 'btcusdt',
      color: Color(0xFFF7931A),
    ),
    CryptoOption(
      symbol: 'ETH',
      name: 'Ethereum',
      wsSymbol: 'ethusdt',
      color: Color(0xFF627EEA),
    ),
    CryptoOption(
      symbol: 'BNB',
      name: 'BNB',
      wsSymbol: 'bnbusdt',
      color: Color(0xFFF3BA2F),
    ),
    CryptoOption(
      symbol: 'SOL',
      name: 'Solana',
      wsSymbol: 'solusdt',
      color: Color(0xFF9945FF),
    ),
    CryptoOption(
      symbol: 'XRP',
      name: 'XRP',
      wsSymbol: 'xrpusdt',
      color: Color(0xFF00AAE4),
    ),
    CryptoOption(
      symbol: 'DOGE',
      name: 'Dogecoin',
      wsSymbol: 'dogeusdt',
      color: Color(0xFFC2A633),
    ),
    CryptoOption(
      symbol: 'ADA',
      name: 'Cardano',
      wsSymbol: 'adausdt',
      color: Color(0xFF0033AD),
    ),
    CryptoOption(
      symbol: 'AVAX',
      name: 'Avalanche',
      wsSymbol: 'avaxusdt',
      color: Color(0xFFE84142),
    ),
    CryptoOption(
      symbol: 'LINK',
      name: 'Chainlink',
      wsSymbol: 'linkusdt',
      color: Color(0xFF2A5ADA),
    ),
    CryptoOption(
      symbol: 'LTC',
      name: 'Litecoin',
      wsSymbol: 'ltcusdt',
      color: Color(0xFFA6A9AA),
    ),
  ];

  late final selectedCrypto = Rx<CryptoOption>(popularCryptos[0]);

  double? _sessionOpenPrice;
  double _prevPrice = 0;
  StreamSubscription<BitcoinTrade>? _sub;

  int _lastAddedMs = 0;
  static const _throttleMs = 500;

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _service.dispose();
    super.onClose();
  }

  void changeCrypto(CryptoOption crypto) {
    selectedCrypto.value = crypto;
    _allTrades.clear();
    _sessionOpenPrice = null;
    _prevPrice = 0;
    _lastAddedMs = 0;
    currentPrice.value = 0;
    priceChange.value = 0;
    priceChangePercent.value = 0;
    isPriceUp.value = true;
    chartSpots.value = [];
    _sub?.cancel();
    _connect();
  }

  void _connect() {
    connectionStatus.value = 'Connecting';
    _service.connect(selectedCrypto.value.wsSymbol);
    _sub?.cancel();
    _sub = _service.tradeStream.listen(
      _onTrade,
      onError: (_) {
        if (!isClosed) {
          connectionStatus.value = 'Reconnecting';
          _scheduleReconnect();
        }
      },
      cancelOnError: false,
    );
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed) _connect();
    });
  }

  void _onTrade(BitcoinTrade trade) {
    connectionStatus.value = 'Live';

    _sessionOpenPrice ??= trade.price;

    _prevPrice = currentPrice.value == 0 ? trade.price : currentPrice.value;
    isPriceUp.value = trade.price >= _prevPrice;

    currentPrice.value = trade.price;
    priceChange.value = trade.price - _sessionOpenPrice!;
    priceChangePercent.value =
        (trade.price - _sessionOpenPrice!) / _sessionOpenPrice! * 100;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastAddedMs < _throttleMs) return;
    _lastAddedMs = now;

    _allTrades.add(trade);
    if (_allTrades.length > _maxStoredTrades) _allTrades.removeAt(0);

    _updateChartSpots();
  }

  void _updateChartSpots() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final windowMs = _windowMs;

    final filtered = _allTrades
        .where((t) => now - t.timestampMs <= windowMs)
        .toList();

    if (filtered.isEmpty) {
      chartSpots.value = [];
      return;
    }

    const maxPoints = 100;
    final List<BitcoinTrade> sampled;
    if (filtered.length <= maxPoints) {
      sampled = filtered;
    } else {
      final step = filtered.length / maxPoints;
      sampled = List.generate(maxPoints, (i) => filtered[(i * step).floor()]);
    }

    final firstMs = sampled.first.timestampMs;
    chartSpots.value = sampled.map((t) {
      final x = (t.timestampMs - firstMs) / 1000.0;
      return FlSpot(x, t.price);
    }).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _updateChartSpots();
  }

  int get _windowMs {
    switch (selectedFilter.value) {
      case '1M':
        return 60 * 1000;
      case '5M':
        return 5 * 60 * 1000;
      case '15M':
        return 15 * 60 * 1000;
      case '1H':
        return 60 * 60 * 1000;
      case '1D':
        return 24 * 60 * 60 * 1000;
      default:
        return 60 * 1000;
    }
  }
}
