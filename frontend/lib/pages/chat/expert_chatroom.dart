import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/date_time_utils.dart';
import 'package:frontend/pages/chat/other_msg.dart';
import 'package:frontend/pages/chat/own_msg.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/socket_service.dart';
import 'package:http/http.dart' as http;

class IndiExpertChat extends StatefulWidget {
  final Map<String, dynamic> chat;

  const IndiExpertChat({
    required this.chat,
    super.key});

  @override
  State<IndiExpertChat> createState() => _IndiExpertChatState();
}

class _IndiExpertChatState extends State<IndiExpertChat> {
  final TextEditingController _messageController = TextEditingController();
  final SocketService _socketService = SocketService();
  final String? backendUrl = dotenv.env['BACKEND_URL'];
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState(){
    super.initState();
    _socketService.initializeSocket(widget.chat['chatId'], onMessageReceived);
    fetchAndSetUserInfo();
    fetchMessages();
  }

  void onMessageReceived(dynamic message) {
    if (message is Map<String, dynamic>) {
      setState(() {
        messages.add(message);
      });
    }
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = {
        'content': _messageController.text,
        'chatId': widget.chat['chatId'],
        'sender': widget.chat['members'][1],
        'receiver': widget.chat['members'][0],
        'createdAt': DateTime.now().toIso8601String(),
      };
      _socketService.sendMessage(
        message['content'],
        message['chatId'],
        message['sender'],
        message['receiver'],
        message['createdAt'],
      );
      setState(() {
        messages.add(message);
      });
      _messageController.clear();
    }
  }

  // Fetch User information and set the state
  Future<void> fetchAndSetUserInfo() async {
    try {
      final info = await fetchUserInfo(widget.chat['members'][0]);
      setState(() {
        userInfo = info;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle the error appropriately in your UI
      // ignore: avoid_print
      print(error);
    }
  }

  // Fetch user information
  Future<Map<String, dynamic>> fetchUserInfo(String userId) async {
    final response = await http.get(Uri.parse('$backendUrl/chat/userinfo/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user information');
    }
  }

  // Fetch messages from the backend (optional)
  Future<void> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/chat/messages/${widget.chat['chatId']}'));
      if (response.statusCode == 200) {
        final List<dynamic> messagesData = json.decode(response.body);
        setState(() {
          messages = messagesData.cast<Map<String, dynamic>>();
        });
        // print("Fetched messages: $messages");
      }
    } catch (error) {
      print('Failed to load messages: $error');
    }
  }

  @override
  void dispose() {
    _socketService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userInfo?['username'] ?? 'User', style: TTtextStyles.bodylargeBold),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userInfo?['profileurl'] != null
                ? NetworkImage(userInfo?['profileurl'])
                : const AssetImage('images/logo.png') as ImageProvider,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isOwnMessage = message['sender'] == widget.chat['members'][1];
                print('Rendering message: $message');
                return isOwnMessage
                    ? OwnMsg(message: message['content'], time: formatTime(message['createdAt']))
                    : OtherMsg(message: message['content'], time: formatTime(message['createdAt']));
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Card(
                      margin: const EdgeInsets.only(left: 5, right: 2, bottom: 8),
                      color: AppColors.backgroundGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 8.0, top: 2, bottom: 2),
                        child: TextFormField(
                          controller: _messageController,
                          // textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type a message',
                            hintStyle: TTtextStyles.bodymediumRegular,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        color: AppColors.primaryColor,
                        onPressed: sendMessage,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}