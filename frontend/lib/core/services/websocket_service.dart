import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _baseUrl = "ws://localhost:8000/api/v1/ws"; // Adjust for prod

  // We use a broadcast stream so multiple widgets can listen to order updates.
  Stream<Map<String, dynamic>>? get stream =>
      _channel?.stream.map((event) => jsonDecode(event) as Map<String, dynamic>).asBroadcastStream();

  void connectToOrder(String orderId) {
    try {
      final url = '$_baseUrl/orders/$orderId';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      debugPrint("Connected to WS: $url");
    } catch (e) {
      debugPrint("WS Connection Error: $e");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
