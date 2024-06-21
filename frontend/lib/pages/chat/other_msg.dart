import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';

class OtherMsg extends StatelessWidget {
  final String message;
  final String time;

  const OtherMsg({
    required this.message,
    required this.time,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // const Padding(
              //   padding: EdgeInsets.all(8.0),
              //   child: CircleAvatar(
              //     radius: 15,
              //     backgroundImage: AssetImage('images/logo.png') as ImageProvider,
              //   ),
              // ),
              Card(
                margin: const EdgeInsets.only(left: 5, right: 3),
                color: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    message,
                    style: TTtextStyles.bodymediumRegular.copyWith(color: AppColors.textColor)),
                ),
              ),
              Text(
                time, 
                style: TTtextStyles.bodysmallRegular.copyWith(
                  color: AppColors.textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}