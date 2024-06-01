// ignore_for_file: prefer_const_constructors

import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/main-screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sign-in-controller.dart'; // Import your signin controller

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
        title: Text('Sign In' , style: TextStyle(color: Colors.white),),
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
              Image.asset('assets/logo_image.png'),
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
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
