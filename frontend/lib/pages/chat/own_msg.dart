import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';

class OwnMsg extends StatelessWidget {
  final String message;
  final String time;

  const OwnMsg({
    required this.message,
    required this.time,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TTtextStyles.bodysmallRegular.copyWith(
                              color: AppColors.textColor.withOpacity(0.5),
              ),),
              Flexible(
                child: Card(
                  margin: const EdgeInsets.only(left: 5, right: 3),
                  color: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      message,
                      style: TTtextStyles.bodymediumRegular.copyWith(color: AppColors.white),
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}