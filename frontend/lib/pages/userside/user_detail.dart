import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/bottomNavigation.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/login.dart';
import 'package:frontend/pages/userside/chg_pwd.dart';
import 'package:frontend/pages/userside/edit_profile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userDetail extends StatefulWidget {
  const userDetail({Key? key}) : super(key: key);

  @override
  State<userDetail> createState() => _userDetailState();
}

class _userDetailState extends State<userDetail> {
  String _profilePhotoUrl = '';
  String _username = 'Username';
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  //Fetch User Detail
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
          _username = userProfile['username'] ?? 'Username';
          _profilePhotoUrl = userProfile['profileurl'] ?? '';
        });
      } else {
        print('Failed to load user profile: ${response.body}');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    if (idToken == null) {
      print('No user token found');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/user/signOut'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        await prefs.remove('token');
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        print('Failed to sign out: ${response.body}');
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _showSignOutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: AppColors.white,
            content: Text(
              "Log out of your account?",
              style: TTtextStyles.bodymediumRegular
                  .copyWith(color: Colors.black, fontSize: 18),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: AppColors.secondaryColor,
                      ),
                      child: Text(
                        "Cancel",
                        style: TTtextStyles.bodymediumBold.copyWith(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        signOut();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Text(
                        "Log Out",
                        style: TTtextStyles.bodymediumBold.copyWith(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    if (idToken == null) {
      print('No user token found');
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('$backendUrl/user/deleteAccount'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        await prefs.remove('token');
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        print('Failed to delete account: ${response.body}');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: AppColors.white,
          content: Text(
            "This action will delete your account permanently.\nAre you sure?",
            style: TTtextStyles.bodymediumRegular.copyWith(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: AppColors.secondaryColor,
                    ),
                    child: Text(
                      "Cancel",
                      style: TTtextStyles.bodymediumBold.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteAccount();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(
                      "Delete",
                      style: TTtextStyles.bodymediumBold.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        toolbarHeight: 10.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProfileHeader(
                profilePhotoUrl: _profilePhotoUrl, username: _username),
            SettingsSection(
              signOutCallback: _showSignOutDialog,
              deleteAccountCallback: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }
}

// class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
//   const CustomAppBar({super.key});

//   @override
//   State<CustomAppBar> createState() => _CustomAppBarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// class _CustomAppBarState extends State<CustomAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => const BottomNav()),
//             (route) => false,
//           ),
//         ));
//   }
// }

class ProfileHeader extends StatelessWidget {
  final String profilePhotoUrl;
  final String username;
  const ProfileHeader({
    required this.profilePhotoUrl,
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProfilePhoto(profilePhotoUrl: profilePhotoUrl),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: ProfileInfo(
                username: username,
              ),
            ),
            const EditProfileButton(),
          ],
        ),
      ),
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  final String profilePhotoUrl;
  const ProfilePhoto({
    required this.profilePhotoUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundColor,
      ),
      child: ClipOval(
        child: profilePhotoUrl.isNotEmpty
            ? Image.network(
                profilePhotoUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'images/default_profile.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final String username;

  const ProfileInfo({
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(username,
            style: TTtextStyles.bodymediumBold
                .copyWith(fontSize: 15, color: AppColors.textColor)),
        const SizedBox(
          height: 8,
        ),
        Text('Edit Profile',
            style: TTtextStyles.bodysmallRegular.copyWith(
              color: AppColors.textColor,
            ))
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_right_rounded),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfile(),
          ),
        );
      },
    );
  }
}

class SettingsSection extends StatelessWidget {
  final VoidCallback signOutCallback;
  final VoidCallback deleteAccountCallback;
  const SettingsSection(
      {required this.signOutCallback,
      required this.deleteAccountCallback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SettingsRow(
              text: 'Change Password',
              onTap: () => navigateToChangePassword(context),
            ),
            const Divider(color: AppColors.primaryColor),
            SettingsRow(
              text: 'Delete My Account',
              onTap: deleteAccountCallback,
            ),
            const Divider(color: AppColors.primaryColor),
            SettingsRow(
              text: 'Log Out',
              onTap: signOutCallback,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SettingsRow({
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TTtextStyles.bodymediumRegular.copyWith(
            color: AppColors.textColor,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void navigateToChangePassword(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
  );
}
