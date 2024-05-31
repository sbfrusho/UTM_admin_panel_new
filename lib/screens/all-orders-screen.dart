// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_unnecessary_containers
import 'package:admin_panel/utils/AppConstant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../const/app-colors.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  late Future<QuerySnapshot> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Orders",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor().colorRed,
      ),
      body: Container(
        color: AppColor().backgroundColor,
        child: FutureBuilder(
          future: _ordersFuture,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
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
                    // onTap: () => Get.to(() => OrderDetails(userId: data['customerId'])),
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
                                      style: ButtonStyle(),
                                      
                                      onPressed: () async {
                                        // Update the status in the "orders" collection to "accepted"
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(data.id)
                                              .update({'status': 'accepted'});
                                          // Show a success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Order accepted successfully'),
                                            ),
                                          );
                                          // Reload the orders after updating the status
                                          setState(() {
                                            _ordersFuture = FirebaseFirestore
                                                .instance
                                                .collection('orders')
                                                .orderBy('createdAt',
                                                    descending: true)
                                                .get();
                                          });
                                        } catch (e) {
                                          // Show an error message if updating the status fails
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to accept order: $e'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('Accept'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          // Delete the order document from Firestore
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(data.id)
                                              .delete();

                                          // Show a success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Order rejected successfully'),
                                            ),
                                          );

                                          // Reload the orders after deleting the order
                                          setState(() {
                                            _ordersFuture = FirebaseFirestore
                                                .instance
                                                .collection('orders')
                                                .orderBy('createdAt',
                                                    descending: true)
                                                .get();
                                          });
                                        } catch (e) {
                                          // Show an error message if deleting the order fails
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to reject order: $e'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
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
