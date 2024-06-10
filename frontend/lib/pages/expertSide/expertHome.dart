import 'package:flutter/material.dart';
import 'package:frontend/pages/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpertHome extends StatefulWidget {
  const ExpertHome({super.key});

  @override
  State<ExpertHome> createState() => _ExpertHomeState();
}

class _ExpertHomeState extends State<ExpertHome> {
  @override
  void initState() {
    super.initState();
    _checkForToken();
  }

  Future<void> _checkForToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // No token found, navigate to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signup()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExpertHome'),
      ),
      body: const Center(
        child: Text('Welcome to the ExpertHome Page!'),
      ),
    );
  }
}
