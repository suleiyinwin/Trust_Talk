import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/expertlogin.dart';
import 'package:frontend/pages/education_content/createpreview.dart';
import 'package:frontend/pages/education_content/expert_contents.dart';
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
    String? expertId = prefs.getString('expertId');

    if (token == null || expertId == null) {
      // No token found, navigate to the login page
      if(mounted){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ExpertLogin()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Container(
          padding:  const EdgeInsets.fromLTRB(5,25,5,0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Welcome back,',style: TTtextStyles.bodylargeRegular.copyWith(color: AppColors.disableColor)),
            ],
          ),
        ),),
       body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0,0,0,0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreatePreview(),
              SizedBox(height: 7,),
              ExpertContents(),
            ],
          ),
        ),
      ),
    );
  }
}
