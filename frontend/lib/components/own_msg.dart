import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';

class OwnMsg extends StatelessWidget {
  const OwnMsg({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('1:04 PM', style: TTtextStyles.bodysmallRegular),
            Card(
              margin: const EdgeInsets.only(left: 5, right: 3),
              color: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Hello, doctor?',     style: TTtextStyles.bodymediumRegular.copyWith(color: AppColors.white)),
              ),
            ),
          ],
        )
      ),
    );
  }
}