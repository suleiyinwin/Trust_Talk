import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/expertlogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ExpertProfile extends StatefulWidget {
  const ExpertProfile({super.key});

  @override
  State<ExpertProfile> createState() => _ExpertProfileState();
}

class _ExpertProfileState extends State<ExpertProfile> {
  final String? backendUrl = dotenv.env['BACKEND_URL'];
  Map<String, dynamic>? expertProfile;

  @override
  void initState() {
    super.initState();
    _loadExpertProfile();
  }

  //Fetch Expert Detail
  Future<void> _loadExpertProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/expert/getExpertProfile'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        setState(() {
          expertProfile = profile;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Update Active Status
  Future<void> _updateActiveStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/expert/updateIsActive'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'isActive': isActive,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          expertProfile?['isActive'] = isActive;
        });
      } else {
        throw Exception('Failed to update active status');
      }
    } catch (e) {
      print('Error updating active status: $e');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    if (idToken == null) {
      print('No user token found');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/expert/signout'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        await prefs.remove('token');
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExpertLogin()),
        );
      } else {
        throw Exception('Failed to sign out');
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: AppColors.white,
          content: Text(
            "Log out of your account?",
            style: TTtextStyles.bodymediumRegular
                .copyWith(color: Colors.black, fontSize: 18),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                      Navigator.of(context).pop();
                      signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(
                      "Log Out",
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
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: expertProfile?['profileurl'] != null
                ? NetworkImage(expertProfile?['profileurl'])
                : const AssetImage('images/logo.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              expertProfile?['name'] ?? 'Expert',
              style: TTtextStyles.bodylargeBold,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle, 
                  color: expertProfile?['isActive'] == true ? Colors.green : Colors.grey, 
                  size: 12
                ),
                const SizedBox(width: 5),
                Text(
                  expertProfile?['isActive'] == true ? 'Active now' : 'Offline',
                  style: TextStyle(color: expertProfile?['isActive'] == true ? Colors.green : Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Active Status'),
                      value: expertProfile?['isActive'] ?? false,
                      activeColor: Colors.white, // color of the switch when active
                      activeTrackColor: Colors.green, // color of the track when active
                      inactiveThumbColor: Colors.white, // color of the thumb when inactive
                      inactiveTrackColor: Colors.grey, // color of the track when inactive
                      onChanged: (bool value) {
                         _updateActiveStatus(value);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Log Out'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showSignOutDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}