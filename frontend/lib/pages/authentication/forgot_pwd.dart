import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/components/colors.dart';

class ForgotPwdModal extends StatefulWidget {
  const ForgotPwdModal({super.key});

  @override
  State<ForgotPwdModal> createState() => _ForgotPwdModalState();
}

class _ForgotPwdModalState extends State<ForgotPwdModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String errorMessage = '';
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/password-reset-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Password reset link successfully sent to $email",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        setState(() {
          _emailController.clear();
        });
      } else {
        setState(() {
          errorMessage = jsonDecode(response.body)['message'];
        });
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print("Error sending password reset link: $e");
    }
  }

  void _handleSendEmail() {
    if (_formKey.currentState!.validate()) {
      sendPasswordResetEmail(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 2, bottom: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                ),
              ),
              Text(
                'Forgot Password',
                style: TTtextStyles.bodymediumRegular.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'We will send a password reset link to your email.',
                style: TTtextStyles.bodymediumRegular.copyWith(
                  fontSize: 15,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      } else if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      } else if (errorMessage.isNotEmpty) {
                        return errorMessage;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        errorMessage = '';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: AppColors.textColor.withOpacity(0.5),
                      ),
                      fillColor: AppColors.backgroundColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: _handleSendEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide.none,
                  ),
                  child: Text(
                    'Send Email',
                    style: TTtextStyles.bodylargeBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
