import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/pages/chat/expert_chats.dart';
import 'package:frontend/pages/expertSide/expert_home.dart';

class ExpertNav extends StatefulWidget {
  const ExpertNav({super.key});

  @override
  State<ExpertNav> createState() => _ExpertNavState();
}

class _ExpertNavState extends State<ExpertNav> {
  int _selectedIndex = 1;

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
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Badge(
                  //change the value of the badge label to the number of unread messages
                  label: Text('2'),
                  child: Icon(Icons.question_answer_outlined)),
              selectedIcon:
                  Icon(Icons.question_answer, color: AppColors.primaryColor),
              label: "Chat",
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryColor),
              label: "Home",
            ),
            NavigationDestination(
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
          children: const <Widget>[
            ChatsPage(),
            ExpertHome(),
            Placeholder(),
          ],
        ),
      ),
    );
  }
}
