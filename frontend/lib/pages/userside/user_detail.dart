
import 'package:flutter/material.dart';
import 'package:frontend/components/bottomNavigation.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';


class userDetail extends StatefulWidget {
  const userDetail({Key? key}) : super(key: key);

  @override
  State<userDetail> createState() => _userDetailState();
}

class _userDetailState extends State<userDetail> {
  final String _profilePhotoUrl = '';
 final String _username = 'Username';
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProfileHeader(
              profilePhotoUrl: _profilePhotoUrl, 
              username: _username
              ),
              const SettingsSection(),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

 @override
  State<CustomAppBar> createState() => _CustomAppBarState();

   @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(
            builder: (context)=> const BottomNav()),
            (route)=>false,
            ),
        )
       
    );
  }
  
}

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
            const SizedBox(width: 16,),
            Expanded(
              child: ProfileInfo(username: username,),
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
  }): super(key: key);

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
        )
        ,),
    );
  }
}

class ProfileInfo extends StatelessWidget {
 final String username;

 const ProfileInfo({
  required this.username,
  Key? key,
 }) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          username,
          style: TTtextStyles.bodymediumBold.copyWith(
            fontSize: 15,
            color: AppColors.textColor
          )
        ),
        const SizedBox(height: 8,),
         Text(
          'Edit Profile',
          style: TTtextStyles.bodysmallRegular.copyWith(
            color: AppColors.textColor,
          )
        )
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_right),
      onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const EditProfile(),
        //   ),
        // );
      },
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({Key? key}) : super(key: key);

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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SettingsRow(
              text: 'Change Password',
              onTap: navigateToChangePassword,
            ),
            Divider(color: AppColors.primaryColor),
            SettingsRow(
              text: 'Delete My Account',
              onTap: _showDeleteAccountDialog,
            ),
            Divider(color: AppColors.primaryColor),
            SettingsRow(
              text: 'Log Out',
              onTap: signOut,
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
                icon: const Icon(Icons.chevron_right),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void navigateToChangePassword() {
  // Navigation logic here
}

void _showDeleteAccountDialog() {
  // Show dialog logic here
}

void signOut() {
  // Sign out logic here
}
