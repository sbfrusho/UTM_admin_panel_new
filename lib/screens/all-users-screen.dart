import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/user-details-screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';// Make sure to import the UserDetailScreen

class AllUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users' , style: TextStyle(color: Colors.white),),
        backgroundColor: AppColor().colorRed,
      ),
      body: Container(
        color: AppColor().backgroundColor,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index].data() as Map<String, dynamic>;
                print(user['email']);
                return UserCard(
                  userId: users[index].id,
                  name: user['name'],
                  email: user['email'],
                  onDelete: () => _deleteUser(context, users[index].id, user['email']),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, String userId, String userEmail) async {
    try {
      // Step 1: Delete user's data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      
      // Step 2: Delete user's account from Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: 'password', // provide the user's password here
      );

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $error'),
        ),
      );
    }
  }
}

class UserCard extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final VoidCallback onDelete;

  const UserCard({
    required this.userId,
    required this.name,
    required this.email,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: userId),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(name),
          subtitle: Text(email),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
