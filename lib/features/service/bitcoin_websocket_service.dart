import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/bitcoin_trade_model.dart';

class BitcoinWebSocketService {
  WebSocketChannel? _channel;

  final _tradeController = StreamController<BitcoinTrade>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<BitcoinTrade> get tradeStream => _tradeController.stream;
  Stream<String> get statusStream => _statusController.stream;

  void connect(String symbol) {
    _closeChannel();
    _statusController.add('Connecting');
    try {
      final url = 'wss://stream.binance.com:9443/ws/$symbol@trade';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _statusController.add('Connected');
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _statusController.add('Error');
      _tradeController.addError(e);
    }
  }

  void _closeChannel() {
    _channel?.sink.close();
    _channel = null;
  }

  void _onData(dynamic data) {
    try {
      final json = jsonDecode(data.toString()) as Map<String, dynamic>;
      if (json['p'] != null && json['T'] != null) {
        _tradeController.add(BitcoinTrade.fromJson(json));
      }
    } catch (_) {}
  }

  void _onError(Object error) {
    _statusController.add('Error');
    _tradeController.addError(error);
  }


  void _onDone() {
    _statusController.add('Disconnected');
    _tradeController.addError(Exception('WebSocket connection closed'));
  }

  void dispose() {
    _closeChannel();
    _tradeController.close();
    _statusController.close();
  }
  
}
