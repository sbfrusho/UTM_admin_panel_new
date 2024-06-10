// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/seller/seller-order.dart';
import 'package:admin_panel/widgets/drawer-widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all-orders-screen.dart';
import 'package:admin_panel/widgets/drawer-widget-admin.dart';

class SellerHomeScreen extends StatelessWidget {
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
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildLineChart(),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAdminButton(
                  context,
                  'Orders List',
                  Icons.list,
                  SellerAllOrdersScreen(),
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
