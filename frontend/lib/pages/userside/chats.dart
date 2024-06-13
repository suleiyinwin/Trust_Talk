import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/userside/chatroom.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Chats', style: TTtextStyles.subtitleBold),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: ListView(
        children: const [
          ChatCard(),
          ChatCard(),
        ],
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => const IndiChat())
        ),
      child: const ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('images/logo.png') as ImageProvider,
        ),
        title: Text('Dr. John Doe', style: TTtextStyles.bodylargeBold),
        subtitle: Row(
          children: [
            Text('You: '),
            Text('Hello, how can I help you?',),
          ],
        ),
        trailing: Text('18:04') ,
      ),
    );
  }
}