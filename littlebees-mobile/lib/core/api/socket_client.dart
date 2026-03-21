import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';

class SocketClient {
  static io.Socket? _socket;
  static final _connectionController = StreamController<bool>.broadcast();
  static bool _isConnecting = false;

  SocketClient._();

  static Stream<bool> get connectionStream => _connectionController.stream;
  static bool get isConnected => _socket?.connected ?? false;

  static Future<io.Socket> getSocket() async {
    if (_socket == null) {
      final token = await SecureTokenStorage.getAccessToken();
      _socket = io.io(
        '${AppConfig.wsBaseUrl}/chat',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token ?? ''})
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(10)
            .build(),
      );

      _socket!.onConnect((_) {
        _connectionController.add(true);
        _isConnecting = false;
      });

      _socket!.onDisconnect((_) {
        _connectionController.add(false);
      });

      _socket!.onConnectError((error) {
        _connectionController.add(false);
        _isConnecting = false;
      });

      _socket!.onReconnect((_) {
        _connectionController.add(true);
      });
    }
    return _socket!;
  }

  static Future<io.Socket> connect() async {
    if (_isConnecting) {
      return _socket!;
    }

    final socket = await getSocket();
    if (!socket.connected) {
      _isConnecting = true;
      final token = await SecureTokenStorage.getAccessToken();
      socket.auth = {'token': token ?? ''};
      socket.connect();
    }
    return socket;
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
    _connectionController.add(false);
  }

  static void dispose() {
    disconnect();
    _connectionController.close();
  }
}
