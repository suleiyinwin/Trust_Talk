import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:http/http.dart' as http;

class ViewContent extends StatefulWidget {
  final String contentId;
  const ViewContent({super.key, required this.contentId});

  @override
  State<ViewContent> createState() => _ViewContentState();
}

class _ViewContentState extends State<ViewContent> {
  String title = '';
  String category = '';
  String readingTime = '';
  String content = '';
  String date = '';
  String expertName = '';
  final String? backendUrl = dotenv.env['BACKEND_URL'];
  String expertProfile = "";
  String contenturl = "";
  String errorMessage = '';


  @override
  void initState() {
    super.initState();
    _getContentData();
  }

  bool isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasScheme &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<void> _getContentData() async {
    try {
      final url = Uri.parse('$backendUrl/edu/getContentData');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'contentId': widget.contentId,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          title = responseBody['title'];
          content = responseBody['content'];
          category = responseBody['category'];
          readingTime = responseBody['readingTime'];
          contenturl = responseBody['contenturl'];
          date = responseBody['date'];
          expertName = responseBody['expertName'];
          expertProfile = responseBody['expertProfile'];
        });
      } else {
        setState(() {
        errorMessage = 'Failed with status code: ${response.statusCode}';
      });
      }
    } catch (e) {
       setState(() {
      errorMessage = 'An error occurred: $e';
    });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: AppBar(
      backgroundColor: AppColors.backgroundColor,
      leading: ModalRoute.of(context)?.canPop == true
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: isValidUrl(contenturl) && contenturl.isNotEmpty
                ? Image.network(
                    contenturl,
                    fit: BoxFit.cover,
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TTtextStyles.subtitleBold),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: isValidUrl(expertProfile) &&
                              expertProfile.isNotEmpty
                          ? NetworkImage(expertProfile)
                          : const AssetImage('images/default_profile.png')
                              as ImageProvider,
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 15),
                    Text(expertName, style: TTtextStyles.bodylargeRegular),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.disableColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(readingTime, style: TTtextStyles.bodymediumBold),
                    const SizedBox(width: 10),
                    const Icon(Icons.circle,
                        size: 5, color: AppColors.textColor),
                    const SizedBox(width: 10),
                    Text(date, style: TTtextStyles.bodymediumBold),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      category,
                      style: TTtextStyles.bodysmallRegular.copyWith(
                        color: AppColors.textColor,
                      ),
                    )),
                const SizedBox(height: 15),
                Text(content, style: TTtextStyles.bodymediumRegular),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}

