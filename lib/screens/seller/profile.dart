import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('controllers').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login'); // Assuming you have a login route
            },
          )
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${userData!['username']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Email: ${userData!['email']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Phone: ${userData!['phone']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Admin: ${userData!['isAdmin']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Active: ${userData!['isActive']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Created On: ${userData!['createdOn'].toDate()}', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
    );
  }
}
