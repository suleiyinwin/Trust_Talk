import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/education_content/create_content.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreatePreview extends StatefulWidget {
  const CreatePreview({super.key});

  @override
  State<CreatePreview> createState() => _CreatePreviewState();
}

class _CreatePreviewState extends State<CreatePreview> {
  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  final String? backendUrl = dotenv.env['BACKEND_URL'];
  String expertProfile = "";
  String expertName = "";

  Future<void> _getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expertIdNullable = prefs.getString('expertId');
      final expertId = expertIdNullable!;
      final url = Uri.parse('$backendUrl/edu/getExpertProfile');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'expertId': expertId,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          expertProfile = responseBody['expertProfile'];
          expertName = responseBody['expertName'];
        });
        print(expertName);
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  void _navigateToCreateContent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateContent()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expertName,
              style: TTtextStyles.bodytext2Bold,
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _navigateToCreateContent,
              child: Row(
                children: [
                  expertProfile.isNotEmpty
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(expertProfile),
                          backgroundColor: Colors.transparent,
                        )
                      : Container(),
                  const SizedBox(width: 20),
                  const Text('Write an educational content.',
                      style: TTtextStyles.bodymediumRegular),
                  const Spacer(),
                  const Icon(Icons.edit,
                      size: 20, color: AppColors.primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}
