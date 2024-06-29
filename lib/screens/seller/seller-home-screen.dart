// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/seller/Seller-all-product.dart';
import 'package:admin_panel/screens/seller/profile.dart';
import 'package:admin_panel/screens/seller/seller-all-categories.dart';
import 'package:admin_panel/screens/seller/seller-all-user.dart';
import 'package:admin_panel/screens/seller/seller-order.dart';
import 'package:admin_panel/widgets/drawer-widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all-orders-screen.dart';
import 'package:admin_panel/widgets/drawer-widget-admin.dart';
import 'package:get/get.dart';

class SellerHomeScreen extends StatefulWidget {
  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int userCount = 0;

  int orderCount = 0;

  int productCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    final productSnapshot = await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      orderCount = orderSnapshot.size;
      productCount = productSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor().colorRed,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // _buildLineChart(),
            _buildInfoCard(),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminButton(
                  context,
                  'Orders List',
                  Icons.list,
                  SellerAllOrderScreen(),
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
                  SellerCategoriesScreen(),
                ),
                _buildAdminButton(
                  context,
                  'Products List',
                  Icons.shopping_bag,
                  SellerAllProductScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
        
        // sets the background color of the `BottomNavigationBar`
        canvasColor: AppColor().colorRed,
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        // primaryColor: Colors.red,
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
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerHomeScreen()),
                  );
                  break;
                case 1:
                  // Handle the Wishlist item tap
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SellerAllProductScreen()));
                  break;
                case 2:
                  // Handle the Categories item tap
                  Get.offAll(SellerAllUsersScreen());
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerCategoriesScreen()),
                  );
                  break;
                case 4:
                  // Handle the Profile item tap
                  Get.offAll(ProfileScreen());
                  break;
              }
            },
          ),
      ),

    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(12),
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
          minX: 0,
          maxX: 7,
          minY: 0,
          maxY: 6,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 3),
                FlSpot(1, 1),
                FlSpot(2, 4),
                FlSpot(3, 3),
                FlSpot(4, 2),
                FlSpot(5, 5),
                FlSpot(6, 4),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: true, color: Colors.lightBlue.withOpacity(0.5),
            ),
            ),
          ],
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