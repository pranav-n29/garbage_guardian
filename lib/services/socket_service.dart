import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
class SocketService {
  io.Socket? _socket;

  void connect({
    void Function(dynamic data)? onSmartBinData,
  }) {
    _socket = io.io(
      'http://3.26.184.112:3001',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true,
        'path': '/socket.io',
      },
    );

    _socket!.onConnect((_) {
      debugPrint('✅ Socket.IO connected to EC2');
      debugPrint('Socket ID: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      debugPrint('❌ Socket.IO disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      debugPrint('❌ Socket.IO connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('❌ Socket.IO error: $error');
    });

    _socket!.on('connection-status', (data) {
      debugPrint('Connection status: $data');
    });

    _socket!.on('smartbin-data', (data) {
      debugPrint('📦 SMART BIN DATA RECEIVED: $data');
      onSmartBinData?.call(data);
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    debugPrint('Socket.IO disconnected');
  }
}
