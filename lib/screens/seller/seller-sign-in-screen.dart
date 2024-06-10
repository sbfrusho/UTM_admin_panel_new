// ignore_for_file: prefer_const_constructors

import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/main-screen.dart';
import 'package:admin_panel/screens/seller/forgot-password-screen.dart';
import 'package:admin_panel/screens/seller/seller-register-screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sign-in-controller.dart'; // Import your signin controller

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() {
    SignInController signInController = SignInController();
    signInController.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text('Sign In', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(MainScreen());
          },
        ),
      ),
      body: Container(
        color: AppColor().backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Image.asset('assets/logo_image.png'),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signIn,
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor().colorRed,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.to(RegisterScreen());
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(color: AppColor().colorRed),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(ForgotPasswordScreen());
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColor().colorRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
