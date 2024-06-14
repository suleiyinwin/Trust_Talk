import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  void connect(String chatId) {
    socket = IO.io(backendUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('connected to socket server');
      socket.emit('join', chatId);
    });

    socket.on('disconnect', (_) {
      print('disconnected from socket server');
    });

    // Add more event handlers as needed
  }

  void disconnect(String chatId) {
    socket.emit('leave', chatId);
    socket.disconnect();
  }

  void sendMessage(String chatId, String message) {
    socket.emit('message', {
      'chatId': chatId,
      'message': message,
    });
  }

  void onMessage(Function(dynamic) callback) {
    socket.on('message', callback);
  }
}
