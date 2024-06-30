// ignore_for_file: prefer_const_constructors, avoid_print, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/seller/Seller-all-product.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:admin_panel/screens/seller/seller-order-item.dart';
import 'package:admin_panel/utils/AppConstant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders(sellerId: FirebaseAuth.instance.currentUser?.email);
  }

  Future<QuerySnapshot> _fetchOrders({String status = 'All', String? sellerId}) async {
    try {
      CollectionReference ordersRef = FirebaseFirestore.instance.collection('orders');

      // Build the query
      Query query = ordersRef.orderBy('createdAt', descending: true);

      if (status != 'All') {
        query = query.where('status', isEqualTo: status);
      }

      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }

      return await query.get();
    } catch (e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        // Handle the case where the index is missing
        print('Firestore index required: ${e.message}');
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
      _ordersFuture = _fetchOrders(status: _selectedStatus, sellerId: FirebaseAuth.instance.currentUser?.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SellerHomeScreen()));
          },
        ),
        title: Text(
          "All Orders",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor().colorRed,
        actions: [
          IconButton(
            icon: Icon(Icons.search , color: Colors.white,),
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
              return Container(
                child: Center(
                  child: Text('Error occurred while fetching orders!'),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return Container(
                child: Center(
                  child: Text('No orders found!'),
                ),
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
                                              content: Text('Order accepted '),
                                            ),
                                          );
                                          // Reload the orders after updating the status
                                          setState(() {
                                            _ordersFuture = _fetchOrders(status: _selectedStatus, sellerId: FirebaseAuth.instance.currentUser?.email);
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
                                        backgroundColor:  Colors.orange,
                                        
                                      ),
                                      onPressed: () async {
                                        // Update the status in the "orders" collection to "accepted"
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(data.id)
                                              .update({'status': 'declined'});
                                          // Show a success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Order declined '),
                                            ),
                                          );
                                          // Reload the orders after updating the status
                                          setState(() {
                                            _ordersFuture = _fetchOrders(status: _selectedStatus, sellerId: FirebaseAuth.instance.currentUser?.email);
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
                                      child: Text('Decline'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[200],
                                      ),
                                      onPressed: () async {
                                        // Update the status in the "orders" collection to "accepted"
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
                                            _ordersFuture = _fetchOrders(status: _selectedStatus, sellerId: FirebaseAuth.instance.currentUser?.email);
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
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColor().colorRed,
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          onTap: (value) {
            if (value == 0) {
              Get.to(SellerHomeScreen());
            } else if (value == 1) {
              Get.to(SellerAllProductScreen());
            } else if (value == 3) {
              Get.to(AllCategoriesScreen());
            } else if (value == 4) {
              Get.to(AdminScreen());
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home, color: AppColor().iconColor,),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag, color: AppColor().iconColor,), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.supervisor_account, color: AppColor().iconColor,), label: 'Customers'),
            BottomNavigationBarItem(icon: Icon(Icons.login, color: AppColor().iconColor,), label: 'Admins'),
          ],
        ),
      ),
    );
  }
}
