import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String phone,
    required bool isAdmin,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore.collection('controllers').doc(userCredential.user!.uid).set({
        'uId': userCredential.user!.uid,
        'username': username,
        'email': email,
        'phone': phone,
        'isAdmin': false, // Assuming a new user is not an admin by default
        'isActive': true, // Assuming a new user is active by default
        'createdOn': Timestamp.now(), // Timestamp of user creation
      });

      print('User signed up successfully');
    } catch (e) {
      print('Error signing up: $e');
      throw e;
    }
  }
}
