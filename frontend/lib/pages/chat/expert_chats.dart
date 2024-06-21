import 'dart:convert';
import 'package:frontend/date_time_utils.dart';
import 'package:frontend/pages/chat/expert_chatroom.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late Future<List<Map<String, dynamic>>> _chatsFuture;
  List<Map<String, dynamic>> chatsWithInfo = [];
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    _chatsFuture = fetchChats();
  }

  Future<List<Map<String, dynamic>>> fetchChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if(token != null) {
    final response = await http.get(
      Uri.parse('$backendUrl/chat/chatlist'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      //fetch userInfo for each chat concurrently reduce loading time
      chatsWithInfo = List<Map<String, dynamic>>.from(jsonResponse);
      await Future.wait(chatsWithInfo.map((chat) async {
        try {
          final additionalData = await fetchAdditionalData(chat['members'][0]);
          if (additionalData.isNotEmpty) {
            chat.addAll(additionalData);
          }
        } catch (e) {
          print('Error fetching additional data: $e');
        }
      }));

      return List<Map<String, dynamic>>.from(jsonResponse);
    } else {
      throw Exception('Failed to load chats');
    }
    } else {
      throw Exception('No token found');
    }
  }

  Future<Map<String, dynamic>> fetchAdditionalData(String userId) async {
    final response = await http.get(Uri.parse('$backendUrl/chat/userinfo/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load additional data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Chats', style: TTtextStyles.subtitleBold),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ChatCard(
                  chat: snapshot.data![index],
                  userInfo: chatsWithInfo[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final Map<String, dynamic> chat;
  final Map<String, dynamic> userInfo;
  
  const ChatCard({
    required this.chat,
    required this.userInfo,
    super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => IndiExpertChat(chat: chat))
        ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: userInfo['profileurl'] != null
                ? NetworkImage(userInfo['profileurl'])
                : const AssetImage('images/logo.png') as ImageProvider,
          ),
          title: Text(userInfo['username'] ?? 'User', style: TTtextStyles.bodylargeBold),
          subtitle: Text(chat['lastMessage']?['content'] ?? '',),
          trailing: Text(
            chat['lastMessage']?['createdAt'] != null
                ? formatTime(chat['lastMessage']!['createdAt'])
                : '',),
        ),
      ),
    );
  }
}