import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/userside/user_detail.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Uint8List? _profileImageBytes;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _profilePhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProfileImage(
                      profileImageBytes: _profileImageBytes,
                      profilePhotoUrl: _profilePhotoUrl,
                      onSelectProfilePhoto: _selectAndUploadProfilePhoto,
                    ),
                    const SizedBox(height: 20),
                    // Username
                    TextFieldWithTitle(
                      title: 'Username',
                      controller: _usernameController,
                    ),
                    // Email
                    TextFieldWithTitle(
                      title: 'Email',
                      controller: _emailController,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: SizedBox(
              width: 280,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const userDetail(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide.none,
                ),
                child: Text(
                  'Update',
                  style: TTtextStyles.bodylargeBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      leading: ModalRoute.of(context)?.canPop == true
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileImage extends StatelessWidget {
  final Uint8List? profileImageBytes;
  final String profilePhotoUrl;
  final VoidCallback onSelectProfilePhoto;

  const ProfileImage({
    Key? key,
    required this.profileImageBytes,
    required this.profilePhotoUrl,
    required this.onSelectProfilePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: profileImageBytes != null
                ? Image.memory(
                    profileImageBytes!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : (profilePhotoUrl.isNotEmpty
                    ? Image.network(
                        profilePhotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return Image.asset(
                            'images/default_profile.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        },
                      )
                    : Image.asset(
                        'images/default_profile.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )),
          ),
          Positioned(
            right: 12,
            bottom: 3,
            child: SizedBox(
              height: 40,
              width: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.black),
                  ),
                  backgroundColor: AppColors.white,
                ),
                onPressed: onSelectProfilePhoto,
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TextFieldWithTitle extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool enabled;

  const TextFieldWithTitle({
    Key? key,
    required this.title,
    required this.controller,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TTtextStyles.bodymediumRegular.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              fillColor: AppColors.backgroundGrey,
              filled: true,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _selectAndUploadProfilePhoto() async {
  // Your code for selecting and uploading profile photo
}
