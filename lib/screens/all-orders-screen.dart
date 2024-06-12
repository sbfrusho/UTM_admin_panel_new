import 'dart:io';

import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/single-order-items.dart';
import 'package:admin_panel/utils/AppConstant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../const/app-colors.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  late Future<QuerySnapshot> _ordersFuture;
  String _selectedStatus = 'All';
  final List<String> _statusOptions = ['All', 'pending', 'accepted', 'declined','in progress'];

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
          IconButton(
            icon: Icon(Icons.print , color: Colors.white,),
            onPressed: () async {
              try {
                await _downloadProductsListAsPdf(context);
              } catch (e) {
                print('Error downloading product list: $e');
                _showErrorDialog(context, 'Error downloading product list: $e');
              }
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
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
                                              content: Text('Order declined '),
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
                                              content: Text('Failed to accept order: $e'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('In progress'),
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
                                    //           content: Text('Order rejected '),
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
  Future<void> _downloadProductsListAsPdf(BuildContext context) async {
    try {
      // Request storage permissions
      if (!await _requestPermissions()) {
        throw Exception('Storage permissions not granted');
      }

      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final products = querySnapshot.docs.map((doc) => doc.data()).toList();

      // Create a PDF document
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index] as Map<String, dynamic>;
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Product Name: ${product['productName']}'),
                      pw.Text('Category: ${product['categoryName']}'),
                      pw.Text('Sale Price: ${product['salePrice']}'),
                      pw.Text('Full Price: ${product['fullPrice']}'),
                      pw.Text('Delivery Time: ${product['deliveryTime']}'),
                      pw.Text('Description: ${product['productDescription']}'),
                      pw.Text('Quantity: ${product['quantity']}'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );

      // Get the directory to save the file
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final path = '${directory.path}/products.pdf';
      final file = File(path);

      // Write the PDF data to the file
      await file.writeAsBytes(await pdf.save());

      print("This is the path file: $file");

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Download Complete'),
            content: Text('The product list has been saved to $path'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error during downloading process: $e');
      _showErrorDialog(context, 'Failed to download product list: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      // Open app settings if permission is permanently denied
      if (await Permission.storage.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, String s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(s),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
