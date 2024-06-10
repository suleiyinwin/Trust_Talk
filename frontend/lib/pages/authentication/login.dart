import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/signup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/userside/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  String errorMessageforapi = '';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool passwordVisibleOne = false; //for eye icon
  bool userCheckforIcon = false;
  @override
  void initState() {
    super.initState();
    passwordVisibleOne = true;
  }

  final String? backendUrl = dotenv.env['BACKEND_URL'];
  void login() async {
    try {
      final url = Uri.parse('$backendUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];

        // Store the token using shared_preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Navigate to the home page or another page
        if (mounted) {
          // Check if the widget is still mounted
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        setState(() {
          errorMessageforapi = 'Failed to log in: ${response.body}';
          print(errorMessageforapi);
        });
      }
    } catch (e) {
      setState(() {
        errorMessageforapi = 'Failed to login ${e.toString()}';
          print(errorMessageforapi);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 170, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  'images/logo.png',
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Error loading splash  image');
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: Text(
                  'Welcome!',
                 style: TTtextStyles.title1Bold.copyWith(
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter an email address';
                    } else if (errorMessage.isNotEmpty) {
                      return errorMessage;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: '   Email',
                    labelStyle: TTtextStyles.bodymediumBold.copyWith(
                      color: AppColors.disableColor,
                    ),

                    fillColor: AppColors.backgroundGrey,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                          color: Colors
                              .red), // Custom border color for validation error
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never, // Hide label when focused
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a password';
                    }
                    return null;
                  },
                  obscureText: passwordVisibleOne,
                  decoration: InputDecoration(
                    labelText: '   Password',
                    labelStyle: TTtextStyles.bodymediumBold.copyWith(
                      color: AppColors.disableColor,
                    ),

                    fillColor: AppColors.backgroundGrey,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                          color: Colors
                              .red), // Custom border color for validation error
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never, // Hide label when focused
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisibleOne
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.disableColor,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisibleOne = !passwordVisibleOne;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                    child:  Text(
                      'Login',
                      style: TTtextStyles.subheadlineBold.copyWith(
                        color: AppColors.white,
                    ),
                  ),
                  ),
                ),
              ),
              // Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'Don\'t you have an account?',
                     style: TTtextStyles.bodymediumBold.copyWith(
                      color: AppColors.textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Signup()),
                      );
                    },
                    child:  Text(
                      'Register now',
                      style: TTtextStyles.bodymediumBold.copyWith(
                        color: AppColors.primaryColor,decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
