import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';

class MapViewCard extends StatelessWidget {
  final String title;
  final String reviews;
  final String description;
  final String status;
  final String hours;

  const MapViewCard({
    Key? key,
    required this.title,
    required this.reviews,
    required this.description,
    required this.status,
    required this.hours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TTtextStyles.bodymediumBold.copyWith(
                color: Colors.black,
                fontSize: 16
              ),
            ),
            const SizedBox(height: 5),
            Text(
              reviews,
              style: TTtextStyles.bodymediumRegular.copyWith(
                color: AppColors.disableColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TTtextStyles.bodymediumRegular.copyWith(
                color: AppColors.disableColor,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  status,
                  style: TTtextStyles.bodymediumRegular.copyWith(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  hours,
                  style: TTtextStyles.bodymediumRegular.copyWith(
                    color: AppColors.disableColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
