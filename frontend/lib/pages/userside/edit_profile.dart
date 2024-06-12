import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _usernameError = '';
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/user/getUserProfile'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final userProfile = jsonDecode(response.body);
        setState(() {
          _emailController.text = userProfile['email'] ?? '';
          _usernameController.text = userProfile['username'] ?? '';
          _profilePhotoUrl = userProfile['profileurl'] ?? '';
        });
      } else {
        print('Failed to load user profile: ${response.body}');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _selectAndUploadProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
            print("Selected profile photo loaded: ${pickedFile.path}");

    }
  }

  Future<void> _updateProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('token');

      if (idToken == null) {
        throw Exception('No user token found');
      }

      final uri = Uri.parse('$backendUrl/user/updateProfile');
      final request = http.MultipartRequest('POST', uri);
      request.fields['idToken'] = idToken;
      request.fields['username'] = _usernameController.text;

      if (_profileImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _profileImageBytes!,
          filename: 'profile.jpg',
        ));
                print("Profile photo added to request");

      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        await prefs.setString('username', _usernameController.text);
        final responseData = jsonDecode(responseBody);
        if (responseData['user'] != null && responseData['user']['profileurl'] != null) {
          final newProfilePhotoUrl = responseData['user']['profileurl'];
          await prefs.setString('profilePhotoUrl', newProfilePhotoUrl);
          print("New profile photo URL: $newProfilePhotoUrl");
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const userDetail(),
          ),
        );
      } else {
        final responseData = jsonDecode(responseBody);
        if (response.statusCode == 400 &&
            responseData['message'] == 'Username already exists') {
          setState(() {
            _usernameError = 'Username already exists. Try again.';
          });
        } else {
          print('Failed to update profile: $responseBody');
        }
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
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
                      errorText: _usernameError,
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
                onPressed: _updateProfile,
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
  final String errorText;

  const TextFieldWithTitle({
    Key? key,
    required this.title,
    required this.controller,
    this.enabled = true,
    this.errorText = '',
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
              errorText: errorText.isEmpty ? null : errorText,
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
