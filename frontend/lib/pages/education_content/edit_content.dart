import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/components/expert_nav.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditContent extends StatefulWidget {
  final String contentId;
  const EditContent({super.key, required this.contentId});

  @override
  State<EditContent> createState() => _EditContentState();
}

class _EditContentState extends State<EditContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Uint8List? _contentImage;
  String? _selectedCategory;
  final List<String> _categories = [
    'STD Knowledge',
    'Women\'s Health',
    'Men\'s Health',
    'Others'
  ];
  String formattedDate = "";
  String errorMessage = "";
  String _readingTime = "1 min read";

  final String? backendUrl = dotenv.env['BACKEND_URL'];

  @override
  void initState() {
    super.initState();
    formattedDate = getCurrentDateFormatted();
    _getContentData();
  }

  String getCurrentDateFormatted() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMMM yyyy');
    return formatter.format(now);
  }

  Future<void> _getContentData() async {
    try {
      final url = Uri.parse('$backendUrl/edu/getContentData');
      print(widget.contentId);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'contentId': widget.contentId,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _titleController.text = responseBody['title'];
          _contentController.text = responseBody['content'];
          _selectedCategory = responseBody['category'];
          _loadImageFromUrl(responseBody['contenturl']);
        });
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _contentImage = response.bodyBytes;
        });
      } else {
        print('Failed to load image');
      }
    } catch (e) {
      print(e);
    }
  }

  String calculateReadingTime(String content) {
    final wordsPerMinute = 150;
    final words = content.split(RegExp(r'\s+')).length;
    final readingTimeMinutes = (words / wordsPerMinute).ceil();
    return '$readingTimeMinutes min read';
  }

  Future<void> _uploadContent() async {
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _contentImage = bytes.buffer.asUint8List();
      });
    }
  }

  Future<void> _updateContent() async {
    try {
      final url = Uri.parse('$backendUrl/edu/updateContent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'contentId': widget.contentId,
          'title': _titleController.text,
          'content': _contentController.text,
          'category': _selectedCategory,
          'readingTime': _readingTime,
          'contentImage': base64Encode(_contentImage!),
          'date': formattedDate,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          // Check if the widget is still mounted
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ExpertNav()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          errorMessage = 'Failed to signup: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to signup: $e';
      });
    }
  }

  Future<void> _deleteContent() async {
    try {
      final url = Uri.parse('$backendUrl/edu/deleteContent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'contentId': widget.contentId,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          // Check if the widget is still mounted
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ExpertNav()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          errorMessage = 'Failed to signup: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to signup: $e';
      });
    }
  }

  void _removeContentImage() {
    setState(() {
      _contentImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryBackgroundColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _contentImage == null
                            ? Column(
                                children: [
                                  Image.asset('images/contentImage.png'),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: _uploadContent,
                                    child: Container(
                                      width: 180,
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 6, 15, 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.upload,
                                            size: 20,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Upload an image',
                                            style: TTtextStyles.bodymediumBold,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Flexible(
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 200,
                                      child: Image.memory(
                                        _contentImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 10,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundGrey,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: _removeContentImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Select a category',
                              hintStyle: TTtextStyles.bodymediumBold,
                            ),
                            value: _selectedCategory,
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category,
                                    style: TTtextStyles.bodymediumBold),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            validator: (value) => value == null
                                ? 'Please select a category'
                                : null,
                          ),
                        ),
                      ),
                      TextFormField(
                        cursorColor: AppColors.textColor,
                        controller: _titleController,
                        style: TTtextStyles.title1Bold,
                        maxLines: null,
                        minLines: 1,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          hintStyle: TTtextStyles.title1Bold,
                          labelStyle: TTtextStyles.title1Bold,
                          focusColor: AppColors.primaryColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
                        child: TextFormField(
                          scrollPadding: const EdgeInsets.only(bottom: 150),
                          cursorColor: AppColors.textColor,
                          controller: _contentController,
                          onChanged: (text) {
                            setState(() {
                              _readingTime = calculateReadingTime(text);
                            });
                          },
                          style: TTtextStyles.bodytext2Regular,
                          maxLines: null,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write your content here ...',
                            hintStyle: TTtextStyles.bodylargeRegular,
                            labelStyle: TTtextStyles.bodylargeRegular,
                            focusColor: AppColors.primaryColor,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some content';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _deleteContent();
                            },
                            child: Text(
                              'Delete',
                              style: TTtextStyles.subheadlineBold
                                  .copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_contentImage != null) {
                                  _updateContent();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please upload a content image'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(milliseconds: 400),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Update',
                              style: TTtextStyles.subheadlineBold
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
