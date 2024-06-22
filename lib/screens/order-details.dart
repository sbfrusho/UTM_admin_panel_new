// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
      bottomNavigationBar: Theme(
        
        data: Theme.of(context).copyWith(
        // sets the background color of the `BottomNavigationBar`
        canvasColor: AppColor().colorRed,
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        primaryColor: Colors.red,
        textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(bodySmall: TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Categories',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminScreen()),
                  );
                  break;
                case 1:
                  // Handle the Wishlist item tap
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AllProductsScreen()));
                  break;
                case 2:
                  // Handle the Categories item tap
                  Get.offAll(AllUsersScreen());
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllCategoriesScreen()),
                  );
                  break;
                case 4:
                  // Handle the Profile item tap
                  // Get.offAll();
                  break;
              }
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
