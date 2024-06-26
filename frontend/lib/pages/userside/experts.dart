import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/chat/chatroom.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/userside/experts_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpertsPage extends StatelessWidget {
  const ExpertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(color: AppColors.backgroundGrey, width: 1.0)),
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Health Experts', style: TTtextStyles.subtitleBold),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: const AllExperts(),
    );
  }
}

// Expert class
class Expert {
  final String expertId;
  final String name;
  final String specialty;
  final String profileUrl;
  final bool isActive;

  Expert({
    required this.expertId,
    required this.name,
    required this.specialty,
    required this.profileUrl,
    required this.isActive,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      expertId: json['expertId'],
      name: json['name'],
      specialty: json['specility'],
      profileUrl: json['profileurl'],
      isActive: json['isActive'],
    );
  }
}

// List of all experts
class AllExperts extends StatefulWidget {
  const AllExperts({super.key});

  @override
  State<AllExperts> createState() => _AllExpertsState();
}

class _AllExpertsState extends State<AllExperts> {
  late Future<List<Expert>> _expertsFuture;
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    _expertsFuture = fetchExperts();
  }

  Future<List<Expert>> fetchExperts() async {
    final response = await http.get(Uri.parse('$backendUrl/chat/expertlist'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((expert) => Expert.fromJson(expert)).toList();
    } else {
      throw Exception('Failed to load experts');
    }
  }

  Future<void> _createChat(String expertId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      // Open chat
      final response = await http.post(
        Uri.parse('$backendUrl/chat/createChat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'expertId': expertId, 'token': token}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final chat = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndiChat(
              chat: chat,
            ),
          ),
        );
      } else {
        throw Exception('Failed to create chat');
      }
    } else {
      // Redirect to login
    }
  }

  Future<void> _refreshExperts() async {
    setState(() {
      _expertsFuture = fetchExperts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshExperts,
        child: FutureBuilder<List<Expert>>(
          future: _expertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No experts found'));
            } else {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ExpertsCard(
                      name: snapshot.data![index].name,
                      specialty: snapshot.data![index].specialty,
                      profileUrl: snapshot.data![index].profileUrl,
                      isActive: snapshot.data![index].isActive,
                      onPressed: () => _createChat(snapshot.data![index].expertId),
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
