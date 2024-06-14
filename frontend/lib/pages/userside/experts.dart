import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/userside/chatroom.dart';
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
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          shape: const Border(
            bottom: BorderSide(color: AppColors.backgroundGrey, width: 1.0)),
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Health Experts', style: TTtextStyles.subtitleBold),
          bottom: TabBar(
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TTtextStyles.subheadlineRegular.copyWith(
              color: AppColors.primaryColor,
            ),
            tabs: const <Widget>[
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Inactive'),
            ],
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: const TabBarView(
          children: <Widget>[
            AllExperts(),
            Center(child: Text('Online experts')),
            Center(child: Text('Offline experts')),
          ],
        ),
      ),
    );
  }
}

//Expert class
class Expert {
  final String expertId;
  final String name;
  final String specialty;
  final String profileUrl;

  Expert({
    required this.expertId,
    required this.name,
    required this.specialty,
    required this.profileUrl,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      expertId: json['expertId'],
      name: json['name'],
      specialty: json['specility'],
      profileUrl: json['profileurl'],
    );
  }
}
//List of all experts
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

      if (response.statusCode == 201) {
        // final chat = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IndiChat(),
          ),
        );
      } else {
        // Handle error
      }
    } else {
      // Redirect to login
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Expert>>(
        future: _expertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No experts found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ExpertsCard(
                  name: snapshot.data![index].name,
                  specialty: snapshot.data![index].specialty,
                  profileUrl: snapshot.data![index].profileUrl,
                  onPressed: () => _createChat(snapshot.data![index].expertId),
                );
              },
            );
          }
        },
      ),
    );
  }
}