import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/seller-screen.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../screens/admin-screen.dart';
class SignInController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isPasswordVisible = false.obs;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userSnapshot = await _firestore
          .collection('controllers')
          .doc(userCredential.user!.uid)
          .get();

      // Check if the document exists and contains the 'isAdmin' field
      if (userSnapshot.exists) {
        // Access isAdmin field safely
        bool isAdmin = userSnapshot.get('isAdmin') ?? false;

        if (isAdmin) {
          // Navigate to admin screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        } else {
          // If user is not an admin, you can handle it here
          // For example, navigate to a regular user screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SellerHomeScreen()),
          );
        }
      } else {
        // Handle case where document doesn't exist
        // For example, show an error message
        print("User document doesn't exist");
      }

      print('User signed in successfully');
    } catch (e) {
      print('Error signing in: $e');
      Fluttertoast.showToast(msg: "Invalid Email" , backgroundColor: AppColor().colorRed);
      // Handle sign-in errors here
      // For example, show a snackbar with the error message
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in')));
    }
  }
}
