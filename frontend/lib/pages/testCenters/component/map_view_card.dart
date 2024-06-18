import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';

class MapViewCard extends StatelessWidget {
  final String title;
  final double rating;
  final int totalReviews;
  final String distance;
  final String description;
  final bool isOpen;
  final String nextOpenHours;
  final String review;

  const MapViewCard({
    required this.title,
    required this.rating,
    required this.totalReviews,
    required this.distance,
    required this.description,
    required this.isOpen,
    required this.nextOpenHours,
    required this.review,
    super.key,
  });

  List<Widget> starRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i < 5; i++) {
      if (i <= rating) {
        stars.add(const Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ));
      } else if (i - rating < 1) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    return stars;
  }

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
            const SizedBox(height: 5),
            Text(
              title,
              style: TTtextStyles.bodymediumBold.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                ...starRating(rating),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  '($totalReviews) . $distance',
                  style: TTtextStyles.bodymediumRegular.copyWith(
                    color: AppColors.disableColor,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
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
                  isOpen ? 'Open' : 'Closed',
                  style: TTtextStyles.bodymediumRegular.copyWith(
                    color: isOpen ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                if (!isOpen)
                  Text(
                    'Opens $nextOpenHours',
                    style: TTtextStyles.bodymediumRegular.copyWith(
                      color: AppColors.disableColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: AppColors.disableColor,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Text(
                  review,
                  style: TTtextStyles.bodymediumRegular.copyWith(
                    color: AppColors.disableColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
