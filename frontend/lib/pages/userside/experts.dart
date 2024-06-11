import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/userside/experts_card.dart';

class ExpertsPage extends StatelessWidget {
  const ExpertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          shape: const Border(
            bottom: BorderSide(color: AppColors.backgroundGrey, width: 1.0)),
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Health Experts', style: TTtextStyles.subtitleBold),
          bottom: TabBar(
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TTtextStyles.subheadlineRegular.copyWith(
              color: AppColors.primaryColor,
            ),
            tabs: const <Widget>[
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Inactive'),
            ],
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: const TabBarView(
          children: <Widget>[
            AllExperts(),
            Center(child: Text('Online experts')),
            Center(child: Text('Offline experts')),
          ],
        ),
      ),
    );
  }
}


//List of all experts
class AllExperts extends StatefulWidget {
  const AllExperts({super.key});

  @override
  State<AllExperts> createState() => _AllExpertsState();
}

class _AllExpertsState extends State<AllExperts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return const ExpertsCard();
        },
      ),
    );
  }
}