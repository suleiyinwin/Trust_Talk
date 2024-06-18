import 'dart:convert';
import 'package:frontend/pages/education_content/edit_content.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpertContents extends StatefulWidget {
  const ExpertContents({super.key});

  @override
  State<ExpertContents> createState() => _ExpertContentsState();
}

class _ExpertContentsState extends State<ExpertContents> {
  final String? backendUrl = dotenv.env['BACKEND_URL'];
  List<Map<String, dynamic>> _contents = [];
  @override
  void initState() {
    super.initState();
    _getContents();
  }

  Future<void> _getContents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expertIdNullable = prefs.getString('expertId');
      final expertId = expertIdNullable!;

      final url = Uri.parse('$backendUrl/edu/expertContents');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'expertId': expertId,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> responseBody =
            jsonDecode(response.body)['expertContents'];
        setState(() {
          _contents = responseBody.cast<Map<String, dynamic>>();
        });
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: _contents.map((content) {
          return ContentWidget(
            category: content['category'],
            title: content['title'],
            date: content['date'],
            contenturl: content['contenturl'],
            contentId: content['contentId'],
          );
        }).toList(),
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final String category;
  final String title;
  final String date;
  final String contenturl;
  final String contentId;
  const ContentWidget({
    super.key,
    required this.category,
    required this.title,
    required this.date,
    required this.contenturl,
    required this.contentId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditContent(contentId: contentId),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                  child: SizedBox(
                    height: 90,
                    width: 130,
                    child: Image.network(
                      contenturl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TTtextStyles.bodymediumBold
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          SizedBox(
                            height: 50, // Fixed height for the title
                            child: Text(
                              title,
                              style: TTtextStyles.bodylargeRegular
                                  .copyWith(color: AppColors.textColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            date,
                            style: TTtextStyles.bodymediumBold
                                .copyWith(color: AppColors.primaryColor),
                          )
                        ]),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 7,
            color: AppColors.backgroundGrey,
          )
        ],
      ),
    );
  }
}
