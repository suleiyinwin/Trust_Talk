import 'package:flutter/material.dart';
import 'package:frontend/pages/authentication/expertlogin.dart';
import 'package:frontend/pages/authentication/splashscreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'trust_talk',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
