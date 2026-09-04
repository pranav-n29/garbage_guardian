import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  void connect({
    void Function(dynamic data)? onSmartBinData,
  }) {
    _socket = io.io(
      'http://13.239.62.11:3001',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true,
        'path': '/socket.io',
      },
    );

    _socket!.onConnect((_) {
      print('✅ Socket.IO connected to EC2');
      print('Socket ID: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      print('❌ Socket.IO disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      print('❌ Socket.IO connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ Socket.IO error: $error');
    });

    _socket!.on('connection-status', (data) {
      print('Connection status: $data');
    });

    _socket!.on('smartbin-data', (data) {
      print('📦 SMART BIN DATA RECEIVED: $data');
      onSmartBinData?.call(data);
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
