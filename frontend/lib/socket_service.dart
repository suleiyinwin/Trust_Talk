import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  final Logger logger = Logger();
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  void initializeSocket(String chatId, Function onMessageReceived) {
    logger.i('Initializing socket connection...');
    socket = IO.io(backendUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.emit("createRoom", chatId);

    //handle incoming messages
    socket.on('recieve message', (message) {
      logger.d('Received message: $message');
      onMessageReceived(message);
    });
  }

  void sendMessage(String message, String chatId, String senderId, String receiverId, String createdAt) {
    if (message.isNotEmpty) {
      logger.i('Sending message: $message');
      socket.emit('sendMessage', {
        'content': message,
        'chatId': chatId,
        'sender': senderId,
        'receiver': receiverId,
        'createdAt': createdAt,
      });
    } else {
      logger.w('Attempted to send an empty message');
    }
  }

  void dispose() {
    logger.i('Disposing socket...');
    socket.dispose();
  }
}
