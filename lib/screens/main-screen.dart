// ignore_for_file: file_names, prefer_const_constructors

import 'package:admin_panel/const/app-colors.dart';
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
        backgroundColor: AppColor().colorRed,
        title: const Text(
          "Admin Panel",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: DrawerWidget(),
      body: Container(
        color: AppColor().backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/image 1.png'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor().colorRed,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 20 , color: Colors.white),
                ),
                onPressed: () {
                  // Navigate to sign-in screen
                  Get.offAll(SignInScreen());
                },
                child: Text('Sign In' , style: TextStyle(color: Colors.white),),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor().colorRed,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 20 , color: Colors.white),
                ),
                onPressed: () {
                  // Navigate to sign-in screen
                  Get.offAll(SignUpScreen());
                },
                child: Text('Sign Up' , style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
