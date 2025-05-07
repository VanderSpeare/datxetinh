import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/../core/Constants.dart';
import '/../widgets/CustomButton.dart';
import '/../widgets/CustomCard.dart';
import '../providers/AuthProvider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  String? _errorMessage;
  String? _backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    final path = await _storage.read(key: Constants.backgroundImageKey);
    if (path != null && await File(path).exists()) {
      setState(() {
        _backgroundImagePath = path;
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'background_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage =
            await File(pickedFile.path).copy('${directory.path}/$fileName');

        await _storage.write(
            key: Constants.backgroundImageKey, value: savedImage.path);
        setState(() {
          _backgroundImagePath = savedImage.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Constants.genericError}: $e'),
          backgroundColor: Constants.errorColor,
        ),
      );
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      try {
        await Provider.of<AuthProvider>(context, listen: false).login(
          _emailController.text,
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: Constants.successColor,
          ),
        );
        Navigator.pushReplacementNamed(context, Constants.tripsRoute);
      } catch (e) {
        setState(() {
          String errorMsg = e.toString().replaceFirst('Exception: ', '');
          if (errorMsg.contains('Invalid credentials')) {
            _errorMessage = 'Email hoặc mật khẩu không đúng';
          } else if (errorMsg.contains('Status 500')) {
            _errorMessage = 'Lỗi server, vui lòng thử lại sau';
          } else {
            _errorMessage = errorMsg;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _backgroundImagePath != null &&
                        File(_backgroundImagePath!).existsSync()
                    ? FileImage(File(_backgroundImagePath!))
                    : AssetImage(Constants.defaultBackgroundImage)
                        as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.defaultPadding,
                    vertical: Constants.defaultPadding * 2,
                  ),
                  child: CustomCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Constants.primaryColor,
                            child: Text(
                              'L',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: Constants.defaultPadding * 2),
                          CustomButton(
                            text: 'Change Background',
                            onPressed: _pickBackgroundImage,
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              } else if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Vui lòng nhập email hợp lệ';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              } else if (value.length < 6) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Tính năng quên mật khẩu sẽ sớm ra mắt!'),
                                    backgroundColor: Constants.errorColor,
                                  ),
                                );
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(color: Constants.primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Constants.errorColor,
                                fontSize: Constants.fontSizeMedium,
                              ),
                            ),
                          SizedBox(height: Constants.defaultPadding),
                          CustomButton(
                            text: authProvider.isLoading
                                ? 'Đang đăng nhập...'
                                : 'ĐĂNG NHẬP',
                            onPressed:
                                authProvider.isLoading ? null : _handleLogin,
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Chưa có tài khoản? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Constants.registerRoute);
                                },
                                child: Text(
                                  'ĐĂNG KÝ',
                                  style: TextStyle(
                                    color: Constants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
