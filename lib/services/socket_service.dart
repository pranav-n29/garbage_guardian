import 'package:flutter/foundation.dart';
import 'package:socket_io_client_new/socket_io_client_new.dart' as io;

class SocketService {
  io.Socket? _socket;

  static const String socketUrl = 'http://52.62.227.19';

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    void Function(dynamic data)? onSmartBinData,
    void Function()? onConnected,
    void Function()? onDisconnected,
    void Function(dynamic error)? onError,
  }) {
    if (_socket?.connected == true) return;

    _socket?.dispose();

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['polling'])
          .setPath('/socket.io')
          .disableAutoConnect()
          .enableReconnection()
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket.IO connected: ${_socket!.id}');
      onConnected?.call();
    });

    _socket!.on('smartbin-data', (data) {
      debugPrint('SMART BIN DATA: $data');
      onSmartBinData?.call(data);
    });

    _socket!.onDisconnect((reason) {
      debugPrint('Socket.IO disconnected: $reason');
      onDisconnected?.call();
    });

    _socket!.onConnectError((error) {
      debugPrint('Socket.IO connection error: $error');
      onError?.call(error);
    });

    _socket!.onError((error) {
      debugPrint('Socket.IO error: $error');
      onError?.call(error);
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}