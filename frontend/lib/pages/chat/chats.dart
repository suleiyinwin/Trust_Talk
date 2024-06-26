import 'dart:convert';
import 'package:frontend/date_time_utils.dart';
import 'package:frontend/pages/chat/chat_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/chat/chatroom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final Function(int) onUnreadCountChanged;

  const ChatPage({
    super.key, 
    required this.onUnreadCountChanged});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<List<Map<String, dynamic>>> _chatsFuture;
  List<Map<String, dynamic>> chatsWithInfo = [];
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    _chatsFuture = fetchChats();
    ChatUpdateNotifier.stream.listen((_) {
      _fetchUpdatedChats();
    });
  }

  Future<void> _fetchUpdatedChats() async {
    setState(() {
      _chatsFuture = fetchChats();
    });
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

        //fetch expertInfo for each chat concurrently reduce loading time
        chatsWithInfo = List<Map<String, dynamic>>.from(jsonResponse);
        await Future.wait(chatsWithInfo.map((chat) async {
          try {
            final additionalData = await fetchAdditionalData(chat['members'][1]);
            if (additionalData.isNotEmpty) {
              chat.addAll(additionalData);
            }
          } catch (e) {
            print('Error fetching additional data: $e');
          }
        }));
        //count unread messages in each chat
        int unreadCount = chatsWithInfo
          .where((chat) => 
            chat['lastMessage']?['read'] == false &&
            chat['lastMessage']?['sender'] != chat['members'][0])
          .length;
        widget.onUnreadCountChanged(unreadCount);

        return List<Map<String, dynamic>>.from(jsonResponse);
      } else {
        throw Exception('Failed to load chats');
      }
    } else {
      throw Exception('No token found');
    }
  }

  Future<Map<String, dynamic>> fetchAdditionalData(String expertId) async {
    final response = await http.get(Uri.parse('$backendUrl/chat/expertinfo/$expertId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load additional data');
    }
  }

  Future<void> deleteChat(String chatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.delete(
        Uri.parse('$backendUrl/chat/deletechat/$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Refresh chat list after deletion
        _fetchUpdatedChats();
      } else {
        throw Exception('Failed to delete chat');
      }
    } else {
      throw Exception('No token found');
    }
  }

  Future<void> _refreshChats() async {
    await _fetchUpdatedChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Chats', style: TTtextStyles.subtitleBold),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshChats,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _chatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No chats found'));
            } else {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      key: Key(snapshot.data![index]['chatId']),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: AppColors.white,
                              content: Text('Are you sure you want to delete this chat?',
                                      style: TTtextStyles.bodymediumRegular.copyWith(color: Colors.black, fontSize: 18),
                              ),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.secondaryColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          backgroundColor: AppColors.secondaryColor,
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TTtextStyles.bodymediumBold.copyWith(
                                              color: AppColors.primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.primaryColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          backgroundColor: AppColors.primaryColor,
                                        ),
                                        child: Text(
                                          "Delete",
                                          style: TTtextStyles.bodymediumBold.copyWith(
                                              color: AppColors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        deleteChat(snapshot.data![index]['chatId']);
                      },
                      background: Container(color: Colors.red),
                      child: ChatCard(
                        chat: snapshot.data![index],
                        expertInfo: chatsWithInfo[index],
                        onChatTap: () {
                          setState(() {
                            _chatsFuture = fetchChats();
                          });
                        },
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final Map<String, dynamic> chat;
  final Map<String, dynamic> expertInfo;
  final VoidCallback onChatTap;
  
  const ChatCard({
    required this.chat,
    required this.expertInfo,
    required this.onChatTap,
    super.key});

  @override
  Widget build(BuildContext context) {
    final bool isUnread = chat['lastMessage']?['read'] == false;
    final isSender = chat['lastMessage']?['sender'] == chat['members'][0];

    return InkWell(
      onTap: () async { await Navigator.push(
        context, MaterialPageRoute(builder: (context) => IndiChat(chat: chat))
        );
        onChatTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: expertInfo['profileurl'] != null
                ? NetworkImage(expertInfo['profileurl'])
                : const AssetImage('images/logo.png') as ImageProvider,
          ),
          title: Text(expertInfo['name'] ?? 'Expert', style: TTtextStyles.bodylargeBold),
          subtitle: Text(
            chat['lastMessage']?['content'] ?? '',
            style: isUnread && !isSender
                ? TTtextStyles.bodymediumBold.copyWith(
                  fontWeight: FontWeight.w700,
                )
                : TTtextStyles.bodymediumRegular.copyWith(
                  color: AppColors.textColor.withOpacity(0.5)
                )),
          trailing: Text(
            chat['lastMessage']?['createdAt'] != null
                ? formatTime(chat['lastMessage']!['createdAt'])
                : '',
            style: isUnread && !isSender
                ? TTtextStyles.bodysmallBold.copyWith(
                  fontWeight: FontWeight.w700,
                )
                : TTtextStyles.bodysmallRegular.copyWith(
                  color: AppColors.textColor.withOpacity(0.5)
                )),
        ),
      ),
    );
  }
}
