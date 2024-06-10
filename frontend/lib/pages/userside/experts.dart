import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';

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
          title: const Text('Health Experts', 
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.36,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryColor
            ),
            tabs: <Widget>[
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

//Card for each expert
class ExpertsCard extends StatefulWidget {
  const ExpertsCard({super.key});

  @override
  State<ExpertsCard> createState() => _ExpertsCardState();
}

class _ExpertsCardState extends State<ExpertsCard> {
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
          child: const ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/doctor.png'),
            ),
            title: Text('Dr. John Doe'),
            subtitle: Text('Cardiologist'),
            trailing: Icon(CupertinoIcons.chat_bubble_2_fill, color: AppColors.primaryColor),
          ),
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