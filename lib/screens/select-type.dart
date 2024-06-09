// main_screen.dart
import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/seller/seller-sign-in-screen.dart';
import 'package:admin_panel/screens/sign-in-screen.dart';
import 'package:admin_panel/utils/AppConstant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Role', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColor().colorRed,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => SignInScreen());
              },
              child: Text('Admin' , style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().colorRed,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.offAll(LoginScreen());
              },
              child: Text('Seller',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().colorRed,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
