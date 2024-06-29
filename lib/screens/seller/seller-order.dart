import 'dart:io';

import 'package:admin_panel/screens/seller/profile.dart';
import 'package:admin_panel/screens/seller/seller-all-categories.dart';
import 'package:admin_panel/screens/seller/seller-all-product.dart';
import 'package:admin_panel/screens/seller/seller-all-user.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:admin_panel/screens/seller/seller-order-item.dart';
import 'package:admin_panel/utils/AppConstant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../const/app-colors.dart';

class SellerAllOrderScreen extends StatefulWidget {
  const SellerAllOrderScreen({Key? key}) : super(key: key);

  @override
  _SellerAllOrderScreenState createState() => _SellerAllOrderScreenState();
}

class _SellerAllOrderScreenState extends State<SellerAllOrderScreen> {
  late Future<QuerySnapshot> _ordersFuture;
  String _selectedStatus = 'All';
  final List<String> _statusOptions = ['All', 'accepted', 'declined', 'in progress'];
  User? sellerId = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<QuerySnapshot> _fetchOrders({String status = 'All'}) async {
    try {
      if (status == 'All') {
        return await FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId!.email)
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        return await FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId!.email)
            .where('status', isEqualTo: status)
            .orderBy('createdAt', descending: true)
            .get();
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        // Handle the case where the index is missing
        print('Firestore index required: ${e.message}');
        // Optionally show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firestore index required. Please create the index.'),
          ),
        );
      } else {
        print('Error fetching orders: $e');
      }
      rethrow;
    }
  }

  void _onSearch() {
    setState(() {
      _ordersFuture = _fetchOrders(status: _selectedStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.offAll(SellerHomeScreen());
          },
        ),
        title: Text(
          "All Orders",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor().colorRed,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    color: AppColor().backgroundColor,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Search Orders',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.0),
                        DropdownButton<String>(
                          value: _selectedStatus,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                          items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor().colorRed,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _onSearch();
                          },
                          child: Text('Search'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        color: AppColor().backgroundColor,
        child: FutureBuilder(
          future: _ordersFuture,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print('Snapshot error: ${snapshot.error}');
              return Center(
                child: Text('Error occurred while fetching orders! ${sellerId!.email}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No orders found!'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];

                return Card(
                  elevation: 5,
                  child: ListTile(
                    onTap: () => Get.offAll(SellerOrderItem(orderId: data.id)),
                    leading: CircleAvatar(
                      backgroundColor: AppConstant.colorRed,
                      child: Text(data['customerName'][0]),
                    ),
                    title: Text(data['customerName']),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: ${data['customerPhone']}'),
                              Text('Address: ${data['customerAddress']}'),
                              Text('Total Price: ${data['totalPrice']} RM'),
                              Text('Delivery Time: ${data['deliveryTime']}'),
                              Text('Status: ${data['status']}'),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () async {
                                        // Update the status in the "orders" collection to "accepted"
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(data.id)
                                              .update({'status': 'accepted'});
                                          // Show a success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Order accepted'),
                                            ),
                                          );
                                          // Reload the orders after updating the status
                                          setState(() {
                                            _ordersFuture = _fetchOrders(status: _selectedStatus);
                                          });
                                        } catch (e) {
                                          // Show an error message if updating the status fails
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to accept order: $e'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('Accept'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                      onPressed: () async {
                                        // Update the status in the "orders" collection to "declined"
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(data.id)
                                              .update({'status': 'declined'});
                                          // Show a success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Order declined'),
                                            ),
                                          );
                                          // Reload the orders after updating the status
                                          setState(() {
                                            _ordersFuture = _fetchOrders(status: _selectedStatus);
                                          });
                                        } catch (e) {
                                          // Show an error message if updating the status fails
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to decline order: $e'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('Decline'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[200],
                                      ),
                                      onPressed: () async {
                                        // Update the status in the "orders" collection to "in progress"
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(data.id)
                                              .update({'status': 'in progress'});
                                          // Show a success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Order in progress'),
                                            ),
                                          );
                                          // Reload the orders after updating the status
                                          setState(() {
                                            _ordersFuture = _fetchOrders(status: _selectedStatus);
                                          });
                                        } catch (e) {
                                          // Show an error message if updating the status fails
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to update order: $e'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('In progress'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        Text(data['createdAt'] != null
                            ? (data['createdAt'] as Timestamp).toDate().toString()
                            : 'No date'),
                        IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () async {
                            final pdf = pw.Document();
                            pdf.addPage(
                              pw.Page(
                                build: (pw.Context context) => pw.Center(
                                  child: pw.Text('Order Details'),
                                ),
                              ),
                            );

                            final directory = await getExternalStorageDirectory();
                            final status = await Permission.storage.request();
                            if (status.isGranted) {
                              final file = File('${directory?.path}/order_${data.id}.pdf');
                              await file.writeAsBytes(await pdf.save());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('PDF downloaded'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Permission denied'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColor().colorRed,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (value) {
          switch (value) {
            case 0:
              Get.offAll(SellerHomeScreen());
              break;
            case 1:
              Get.offAll(SellerAllProductScreen());
              break;
            case 2:
              Get.offAll(SellerAllOrderScreen());
              break;
            case 3:
              Get.offAll(SellerCategoriesScreen());
              break;
            case 4:
              Get.offAll(SellerAllUsersScreen());
              break;
            case 5:
              Get.offAll(ProfileScreen());
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
