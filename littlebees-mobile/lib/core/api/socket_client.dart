import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';

class SocketClient {
  static io.Socket? _socket;

  SocketClient._();

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
            .setReconnectionAttempts(5)
            .build(),
      );
    }
    return _socket!;
  }

  static Future<io.Socket> connect() async {
    final socket = await getSocket();
    if (!socket.connected) {
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
  }
}
