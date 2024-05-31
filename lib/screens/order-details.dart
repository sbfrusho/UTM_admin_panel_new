// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:admin_panel/const/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetails extends StatelessWidget {
  final String userId;

  OrderDetails({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor().colorRed,
      ),
      body: Container(
        color: AppColor().backgroundColor,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('orders').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching user data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User not found'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoRow('Name', userData['customerNmae'], Icons.person),
                      _buildDivider(),
                      _buildUserInfoRow('Phone', userData['customerPhone'], Icons.email),
                      _buildDivider(),
                      _buildUserInfoRow('Delivery Time', userData['deliveryTime'], Icons.lock_clock),
                      _buildDivider(),
                      _buildUserInfoRow('Payment Method', userData['deliveryTime'], Icons.payment),
                      _buildDivider(),
                      _buildUserInfoRow('Total Price', userData['totalPrice'], Icons.price_change),
                      _buildDivider(),
                      // _buildUserInfoRow('Address', userData['address'], Icons.home),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColor().colorRed, size: 30),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 30,
      thickness: 1,
      color: Colors.grey[300],
    );
  }
}
