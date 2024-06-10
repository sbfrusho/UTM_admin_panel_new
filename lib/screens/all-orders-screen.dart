import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/single-order-items.dart';
import 'package:admin_panel/utils/AppConstant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/app-colors.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  late Future<QuerySnapshot> _ordersFuture;
  String _selectedStatus = 'All';
  final List<String> _statusOptions = ['All', 'pending', 'accepted', 'declined'];

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
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        return await FirebaseFirestore.instance
            .collection('orders')
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
            Get.offAll(AdminScreen());
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
                    onTap: () => Get.offAll(OrderItemsScreen(orderId: data.id)),
                    leading: CircleAvatar(
                      backgroundColor: AppConstant.colorRed,
                      child: Text(data['customerName'][0]),
                    ),
                    title: Text(data['customerName']),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${data['customerPhone']}'),
                            Text('Address: ${data['customerAddress']}'),
                            Text('Total Price: ${data['totalPrice']} RM'),
                            Text('Delivery Time: ${data['deliveryTime']}'),
                            Text('Status: ${data['status']}'),
                          ],
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
                                              content: Text('Order accepted successfully'),
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
                                              content: Text('Order declined successfully'),
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
                                              .update({'status': 'pending'});
                                          // Show a success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Order pending successfully'),
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
                                      child: Text('Pending'),
                                    ),
                                    // ElevatedButton(
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Colors.red[200],
                                    //   ),
                                    //   onPressed: () async {
                                    //     try {
                                    //       // Delete the order document from Firestore
                                    //       await FirebaseFirestore.instance
                                    //           .collection('orders')
                                    //           .doc(data.id)
                                    //           .delete();

                                    //       // Show a success message
                                    //       ScaffoldMessenger.of(context).showSnackBar(
                                    //         SnackBar(
                                    //           content: Text('Order rejected successfully'),
                                    //         ),
                                    //       );

                                    //       // Reload the orders after deleting the order
                                    //       setState(() {
                                    //         _ordersFuture = _fetchOrders(status: _selectedStatus);
                                    //       });
                                    //     } catch (e) {
                                    //       // Show an error message if deleting the order fails
                                    //       ScaffoldMessenger.of(context).showSnackBar(
                                    //         SnackBar(
                                    //           content: Text('Failed to reject order: $e'),
                                    //         ),
                                    //       );
                                    //     }
                                    //   },
                                    //   child: Text('Reject'),
                                    // ),
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
    );
  }
}
