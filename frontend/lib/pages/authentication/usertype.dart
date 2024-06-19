import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/expertlogin.dart';
import 'package:frontend/pages/authentication/signup.dart';

class UserType extends StatelessWidget {
  const UserType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'User',
                style: TTtextStyles.bodylargeBold
                    .copyWith(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ExpertLogin()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Health Expert',
                style: TTtextStyles.bodylargeBold
                    .copyWith(color: AppColors.primaryColor),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
