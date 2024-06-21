import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';

class ExpertsCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String profileUrl;
  final bool isActive;
  final VoidCallback onPressed;

  const ExpertsCard({
    required this.name,
    required this.specialty,
    required this.profileUrl,
    required this.isActive,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 10.0),
      child: SizedBox(
        child: Card(
          color: AppColors.secondaryBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: Stack(
              children: [
                CircleAvatar(
                radius: 30,
                backgroundImage: profileUrl.isNotEmpty
                    ? NetworkImage(profileUrl)
                    : const AssetImage('images/logo.png') as ImageProvider,
              ),
              if (isActive)
                Positioned(
                  bottom: 1,
                  right: 5,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.secondaryBackgroundColor,
                          width: 2,
                        ),
                    ),
                  ),
                ),
            ],
          ),
            title: Text(name),
            subtitle: Text(specialty),
            trailing: IconButton(
              icon: const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: AppColors.primaryColor,
              ),
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}