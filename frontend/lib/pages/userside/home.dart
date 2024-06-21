import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = "";
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    _checkForToken();
  }

  Future<void> _checkForToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      // No token found, navigate to the login page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Signup()),
          (route) => false,
        );
      }
    }
  }

  Future<String> _getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdNullable = prefs.getString('userId');
      final userId = userIdNullable!;
      final url = Uri.parse('$backendUrl/edu/getUser');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'userId': userId,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['username'];
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: FutureBuilder<String>(
          future: _getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              username = snapshot.data ?? '';

              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    const SliverAppBar(
                      backgroundColor: AppColors.backgroundColor,
                      toolbarHeight: 0,
                      pinned: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TTtextStyles.bodylargeRegular
                                  .copyWith(color: AppColors.disableColor),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              username,
                              style: TTtextStyles.bodytext2Bold
                                  .copyWith(color: AppColors.textColor),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          isScrollable: true,
                          labelColor: AppColors.textColor,
                          unselectedLabelColor: AppColors.disableColor,
                          labelPadding: EdgeInsets.symmetric(horizontal: 12),
                          indicatorColor: AppColors.primaryColor,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: TTtextStyles.bodylargeBold,
                          tabs: [
                            Tab(text: 'All'),
                            Tab(text: 'STD Knowledge'),
                            Tab(text: 'Women\'s Health'),
                            Tab(text: 'Men\'s Health'),
                            Tab(text: 'Others'),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: const TabBarView(
                  children: [
                    Center(child: Text('Tab 1')),
                    Center(child: Text('Tab 2')),
                    Center(child: Text('Tab 3')),
                    Center(child: Text('Tab 4')),
                    Center(child: Text('Tab 5')),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
