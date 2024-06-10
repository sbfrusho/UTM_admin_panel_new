import 'package:admin_panel/screens/main-screen.dart';
import 'package:admin_panel/screens/select-type.dart';
import 'package:admin_panel/screens/seller/seller-sign-in-screen.dart';
import 'package:admin_panel/screens/sign-up-screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sing-up-controller.dart'; // Import your signup controller

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isAdmin = false;

  void _signUp() {
    SignUpController signUpController = SignUpController();
    signUpController.signUpWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      phone: _phoneController.text,
      isAdmin: _isAdmin,
    );
    Get.offAll(LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(SelectTypeScreen());
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
