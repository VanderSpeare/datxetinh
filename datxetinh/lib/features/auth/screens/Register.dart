import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import '/../../core/Constants.dart';
import '/../../widgets/CustomButton.dart';
import '/../../widgets/CustomCard.dart';
import '/../../widgets/CommonWidget.dart';
import '../providers/AuthProvider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  String? _errorMessage;
  String? _backgroundImagePath;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Background image updated successfully!'),
                backgroundColor: Constants.successColor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to pick image: $e'),
              backgroundColor: Constants.errorColor),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      developer
          .log('Attempting to register with email: ${_emailController.text}');
      try {
        await Provider.of<AuthProvider>(context, listen: false).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: 'user',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Registration successful!'),
                backgroundColor: Constants.successColor),
          );
          Navigator.pushReplacementNamed(context, Constants.tripsRoute);
        }
      } catch (e) {
        developer.log('Registration error in Register: $e');
        if (mounted) {
          String error = e.toString();
          if (error.contains('TimeoutException')) {
            error =
                'Connection timed out. Please check your internet connection.';
          } else if (error.contains('API Error')) {
            error = error
                .replaceFirst('Exception: ', '')
                .replaceFirst('API Error: ', '');
          } else {
            error = error.replaceAll('Exception: Registration failed: ', '');
          }
          setState(() {
            _errorMessage =
                error.isNotEmpty ? error : 'Unknown registration error';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_errorMessage!),
                backgroundColor: Constants.errorColor),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    Colors.black.withOpacity(0.3), BlendMode.darken),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Constants.primaryColor,
                            child: Icon(Icons.person_add,
                                size: 40, color: Colors.white),
                          ),
                          SizedBox(height: Constants.defaultPadding * 2),
                          CustomButton(
                            text: 'Change Background',
                            onPressed: _pickBackgroundImage,
                            isLoading: false,
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
                              prefixIcon: Icon(Icons.email,
                                  color: Constants.primaryColor),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock,
                                  color: Constants.primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Constants.primaryColor,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.defaultBorderRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock,
                                  color: Constants.primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Constants.primaryColor,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              } else if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          if (_errorMessage != null)
                            buildErrorMessage(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Constants.defaultPadding),
                            ),
                          SizedBox(height: Constants.defaultPadding),
                          CustomButton(
                            text: _isLoading ? 'Registering...' : 'REGISTER',
                            onPressed: _isLoading ? null : _handleRegister,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: Constants.defaultPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: Constants.fontSizeSmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, Constants.loginRoute),
                                child: Text(
                                  'LOG IN',
                                  style: TextStyle(
                                    color: Constants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Constants.fontSizeSmall,
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
