import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/pages/chat/expert_chats.dart';
import 'package:frontend/pages/expertSide/expert_home.dart';
import 'package:frontend/pages/expertSide/expert_profile.dart';

class ExpertNav extends StatefulWidget {
  final int unreadCount;

  const ExpertNav({
    this.unreadCount = 0,
    super.key});

  @override
  State<ExpertNav> createState() => _ExpertNavState();
}

class _ExpertNavState extends State<ExpertNav> {
  int _selectedIndex = 1;
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
              selectedIcon:
                  const Icon(Icons.question_answer, color: AppColors.primaryColor),
              label: "Chat",
            ),
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryColor),
              label: "Home",
            ),
            const NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon:
                    Icon(Icons.account_circle, color: AppColors.primaryColor),
                label: "Profile"),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            ChatsPage(onUnreadCountChanged: updateBadgeCount),
            const ExpertHome(),
            const ExpertProfile(),
          ],
        ),
      ),
    );
  }
}
