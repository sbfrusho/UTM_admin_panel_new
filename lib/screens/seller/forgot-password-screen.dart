import 'package:admin_panel/screens/seller/seller-sign-in-screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../const/app-colors.dart';
import '../../controllers/forgot-password-controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordController _forgotPasswordController = Get.put(ForgotPasswordController());
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _errorMessage = 'Password reset email sent. Please check your inbox.';
        Fluttertoast.showToast(msg: _errorMessage);
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor().colorRed,
          title: const Text('Forgot Password'),
          leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
            Navigator.pop(context);
          },),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text("Email"),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    labelText: 'Email',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                  width: 100.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColor().colorRed,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          _resetPassword();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                          Fluttertoast.showToast(msg: "Password reset email sent. Please check your inbox.");
                        },
                        child: const Text("Send" ,style: TextStyle(color: Colors.white),))
                    ],
                  ),
                            ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}