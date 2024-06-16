import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/other_msg.dart';
import 'package:frontend/components/own_msg.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/socket_service.dart';
import 'package:http/http.dart' as http;

class IndiChat extends StatefulWidget {
  final Map<String, dynamic> chat;

  const IndiChat({
    required this.chat,
    super.key});

  @override
  State<IndiChat> createState() => _IndiChatState();
}

class _IndiChatState extends State<IndiChat> {
  final TextEditingController _messageController = TextEditingController();
  final SocketService socketService = SocketService();
  final String? backendUrl = dotenv.env['BACKEND_URL'];
  Map<String, dynamic>? expertInfo;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    fetchAndSetExpertInfo();
  }

  Future<void> fetchAndSetExpertInfo() async {
    try {
      final info = await fetchExpertInfo(widget.chat['members'][1]);
      setState(() {
        expertInfo = info;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle the error appropriately in your UI
      print(error);
    }
  }

  Future<Map<String, dynamic>> fetchExpertInfo(String expertId) async {
    final response = await http.get(Uri.parse('$backendUrl/chat/expertinfo/$expertId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load expert information');
    }
  }


  @override
  void dispose() {
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
            Text(expertInfo?['name'] ?? 'Unknown', style: TTtextStyles.bodylargeBold),
            Text(
              expertInfo?['isActive'] == true ? 'online' : 'offline',
              style: TTtextStyles.bodymediumRegular),
          ],
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ListView(
              children: const [
                OwnMsg(),
                OtherMsg(),
              ],
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
                        onPressed: () {},
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