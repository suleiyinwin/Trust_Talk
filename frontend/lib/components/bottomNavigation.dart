import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/pages/chat/chats.dart';
import 'package:frontend/pages/userside/experts.dart';
import 'package:frontend/pages/testCenters/map_view.dart';
import 'package:frontend/pages/userside/home.dart';
import 'package:frontend/pages/userside/user_detail.dart';

class BottomNav extends StatefulWidget {
  final int unreadCount;

  const BottomNav({
    super.key, 
    this.unreadCount = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 2;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadCount = widget.unreadCount;
  }

  void updateBadgeCount(int count) {
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          border: Border(
            top: BorderSide(
              color: AppColors.backgroundGrey,
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          surfaceTintColor: AppColors.backgroundColor,
          indicatorColor: AppColors.backgroundColor,
          backgroundColor: AppColors.backgroundColor,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: _unreadCount > 0
                  ? Badge(
                      label: Text('$_unreadCount'),
                      child: const Icon(Icons.question_answer_outlined),
                    )
                  : const Icon(Icons.question_answer_outlined),
              selectedIcon: const Icon(Icons.question_answer, color: AppColors.primaryColor), 
              label: "Chat",),
            const NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups, color: AppColors.primaryColor), 
              label: "Experts",),
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryColor), 
              label: "Home",),
            const NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on, color: AppColors.primaryColor), 
              label: 'Clinics'),
            const NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle, color: AppColors.primaryColor), 
              label: 'Profile'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            ChatPage(onUnreadCountChanged: updateBadgeCount),
            const ExpertsPage(),
            const Home(),
            const MapView(),
            const userDetail(),
          ],
        ),
      ),
    );
  }
}