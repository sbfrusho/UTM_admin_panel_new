// ignore_for_file: file_names, prefer_const_constructors

import 'package:admin_panel/screens/sign-in-screen.dart';
import 'package:admin_panel/screens/sign-up-screen.dart';
import 'package:admin_panel/utils/constant.dart';
import 'package:admin_panel/widgets/drawer-widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.colorRed,
        title: const Text("Admin Panel"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to sign-in screen
                Get.offAll(SignInScreen());
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Navigate to sign-up screen
                Get.offAll(SignUpScreen());
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
