import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';

class OtherMsg extends StatelessWidget {
  const OtherMsg({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('images/logo.png') as ImageProvider,
              ),
            ),
            Card(
              margin: const EdgeInsets.only(left: 5, right: 3),
              color: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Hello',     style: TTtextStyles.bodymediumRegular.copyWith(color: AppColors.white)),
              ),
            ),
            const Text('1:04 PM', style: TTtextStyles.bodysmallRegular),
          ],
        )
      ),
    );
  }
}