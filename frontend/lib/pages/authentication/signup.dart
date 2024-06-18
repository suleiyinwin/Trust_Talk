import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/authentication/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool passwordVisibleOne = false; //for eye icon
  bool passwordVisibleTwo = false; //for eye icon
  final userNameRegx = RegExp(r'^[a-zA-Z0-9_-]+$');
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");

  bool userCheckforIcon = false;
  @override
  void initState() {
    super.initState();
    passwordVisibleOne = true;
    passwordVisibleTwo = true;
  }

  final String? backendUrl = dotenv.env['BACKEND_URL'];
  void signUp() async {
    try {
      final url = Uri.parse('$backendUrl/auth/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          // Check if the widget is still mounted
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        setState(() {
          errorMessage = 'Failed to signup: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to signup: ${e.toString()}';
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
                  'Join Us',
                  style: TTtextStyles.title1Bold.copyWith(
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a username';
                    } else if (!userNameRegx.hasMatch(value)) {
                      userCheckforIcon = true;
                      return 'Username must contain only letters and numbers';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: '   Username',
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
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter an email address';
                    } else if (!emailRegex.hasMatch(value)) {
                      return 'Email address is not valid';
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
                    } else if (!passwordRegex.hasMatch(value)) {
                      return 'Password must contain at least 6 characters, one uppercase letter, one lowercase letter, one number and one special character';
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: passwordVisibleTwo,
                  decoration: InputDecoration(
                    labelText: '   Confirm Password',
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
                        passwordVisibleTwo
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.disableColor,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisibleTwo = !passwordVisibleTwo;
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
                        signUp();
                      }
                    },
                    child: Text(
                      'Register',
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
                    'Already have an account?',
                    style: TTtextStyles.bodymediumBold
                        .copyWith(color: AppColors.textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text(
                      'Login',
                      style: TTtextStyles.bodymediumBold.copyWith(
                        color: AppColors.primaryColor,
                        decoration: TextDecoration.underline,
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
