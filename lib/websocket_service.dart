import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService with ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String token, Function(String) onMessageReceived) {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('ws://192.168.0.108:8081/api/chats/ws?token=$token'),
    );

    _channel!.stream.listen(
          (data) {
        onMessageReceived(data);
      },
      onError: (error) {
        _isConnected = false;
        print("WebSocket error: $error");
      },
      onDone: () {
        _isConnected = false;
        print("WebSocket closed");
      },
    );

    _isConnected = true;
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void sendMessage(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
    } else {
      print("WebSocket not connected");
    }
  }
}
