import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all-orders-screen.dart';
import 'package:admin_panel/widgets/drawer-widget-admin.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this line for Firestore

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int userCount = 0;
  int orderCount = 0;
  int productCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    final productSnapshot = await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      userCount = userSnapshot.size;
      orderCount = orderSnapshot.size;
      productCount = productSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor().colorRed,
      ),
      drawer: DrawerAdminWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildInfoCard(), // Use the new info card widget here
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminButton(
                  context,
                  'Users List',
                  Icons.people,
                  AllUsersScreen(),
                ),
                _buildAdminButton(
                  context,
                  'Orders List',
                  Icons.list,
                  AllOrdersScreen(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminButton(
                  context,
                  'Categories List',
                  Icons.category,
                  AllCategoriesScreen(),
                ),
                _buildAdminButton(
                  context,
                  'Products List',
                  Icons.shopping_bag,
                  AllProductsScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: new Theme(
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
          backgroundColor: AppColor().colorRed,
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

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildInfoRow('Users', userCount, Icons.people),
          SizedBox(height: 8),
          _buildInfoRow('Orders', orderCount, Icons.list),
          SizedBox(height: 8),
          _buildInfoRow('Products', productCount, Icons.shopping_bag),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, int count, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAdminButton(BuildContext context, String title, IconData icon, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        minimumSize: Size(150, 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
