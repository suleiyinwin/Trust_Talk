import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  bool _currentPasswordVisible = true;
  bool _newPasswordVisible = true;
  bool _confirmNewPasswordVisible = true;
  String _errorMessage = '';
  String _currentPasswordError = '';
  bool newPasswordError = false;
  String newPasswordErrorText = '';
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");

  @override
  void initState() {
    super.initState();
    _currentPasswordVisible = true;
    _newPasswordVisible = true;
    _confirmNewPasswordVisible = true;
  }

  final String? backendUrl = dotenv.env['BACKEND_URL'];

  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = '';
      _currentPasswordError = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('token');

    if (idToken == null) {
      setState(() {
        _errorMessage = 'No user token found';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/user/changePassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          if (responseData['message'] == 'Wrong current password. Try again.') {
            _currentPasswordError = responseData['message'];
          } else {
            _errorMessage =
                responseData['message'] ?? 'Failed to change password';
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to change password: $e';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextFieldWithTitle(
                        title: 'Current Password',
                        controller: _currentPasswordController,
                        obscureText: _currentPasswordVisible,
                        errorText: _currentPasswordError,
                        onToggleVisibility: () {
                          setState(() {
                            _currentPasswordVisible = !_currentPasswordVisible;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _currentPasswordError = '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your password';
                          } else if (_currentPasswordError.isNotEmpty) {
                            return _currentPasswordError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFieldWithTitle(
                        title: 'New Password',
                        controller: _newPasswordController,
                        obscureText: _newPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _newPasswordVisible = !_newPasswordVisible;
                          });
                        },
                        validator: (value) {
                          setState(() {
                            newPasswordError = false;
                            newPasswordErrorText = '';
                          });
                          if (value == null || value.isEmpty) {
                            setState(() {
                              newPasswordError = true;
                              newPasswordErrorText = 'Please Enter a password';
                            });
                            return newPasswordErrorText;
                          } else if (!passwordRegex.hasMatch(value)) {
                            setState(() {
                              newPasswordError = true;
                              newPasswordErrorText =
                                  'Password must contain at least 6 characters, including:\n'
                                  '• Uppercase\n'
                                  '• Lowercase\n'
                                  '• Numbers and special characters';
                            });
                            return newPasswordErrorText;
                          }
                          return null;
                        },
                        helperText: !newPasswordError
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password must contain at least 6 characters, including:\n'
                                    '• Uppercase\n'
                                    '• Lowercase\n'
                                    '• Numbers and special characters',
                                    style: TTtextStyles.bodysmallRegular
                                        .copyWith(fontSize: 12),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFieldWithTitle(
                        title: 'Confirm New Password',
                        controller: _confirmNewPasswordController,
                        obscureText: _confirmNewPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _confirmNewPasswordVisible =
                                !_confirmNewPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your password again';
                          } else if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: SizedBox(
              width: 280,
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
                    _changePassword();
                  }
                },
                child: Text(
                  'Change Password',
                  style: TTtextStyles.subheadlineBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextFieldWithTitle extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? errorText;
  final Widget? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const TextFieldWithTitle({
    super.key,
    required this.title,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.errorText,
    this.helperText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TTtextStyles.bodymediumRegular.copyWith(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 13.0, horizontal: 8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            fillColor: AppColors.backgroundGrey,
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: AppColors.disableColor,
              ),
              onPressed: onToggleVisibility,
            ),
            errorText: errorText,
            errorMaxLines: 5,
          ),
          validator: validator,
        ),
        if (helperText != null && (errorText == null || errorText!.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: helperText!,
          ),
      ],
    );
  }
}
