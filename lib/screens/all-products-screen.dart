// import 'dart:io';
// import 'package:admin_panel/controllers/category-dropdown_controller.dart';
// import 'package:admin_panel/screens/add-products-screen.dart';
// import 'package:admin_panel/screens/admin-screen.dart';
// import 'package:admin_panel/screens/all-users-screen.dart';
// import 'package:admin_panel/screens/all_categories_screen.dart';
// import 'package:admin_panel/screens/edit-product-screen.dart';
// import 'package:admin_panel/screens/product-detail-screen.dart';
// import 'package:admin_panel/screens/seller/profile.dart';
// import 'package:admin_panel/screens/seller/seller-add-product.dart';
// import 'package:admin_panel/screens/seller/seller-all-categories.dart';
// import 'package:admin_panel/screens/seller/seller-all-user.dart';
// import 'package:admin_panel/screens/seller/seller-home-screen.dart';
// import 'package:admin_panel/screens/user-details-screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pdf/widgets.dart' as pw;

// import '../../const/app-colors.dart';
// import '../../controllers/is-sale-controller.dart';
// import '../../models/product-model.dart';
// import '../../utils/AppConstant.dart';

// class SellerAllProductScreen extends StatefulWidget {
//   const SellerAllProductScreen({super.key});

//   @override
//   State<SellerAllProductScreen> createState() => _SellerAllProductScreenState();
// }

// class _SellerAllProductScreenState extends State<SellerAllProductScreen> {
//   User? user = FirebaseAuth.instance.currentUser;
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Get.offAll(SellerHomeScreen());
//           },
//         ),
//         title: Text("All Products", style: TextStyle(color: Colors.white) , ),
//         actions: [
//           GestureDetector(
            
//             onTap: () => Get.to(() => SellerAddProductScreen()),
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Icon(Icons.add , color: Colors.white,),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.print , color: Colors.white,),
//             onPressed: () async {
//               try {
//                 await _downloadProductsListAsPdf(context);
//               } catch (e) {
//                 print('Error downloading product list: $e');
//                 _showErrorDialog(context, 'Error downloading product list: $e');
//               }
//             },
//           ),
//         ],
//         backgroundColor: AppColor().colorRed,
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//                   .collection('products').where('email', isEqualTo: user!.email.toString())
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Container(
//               child: Center(
//                 child: Text('Error occurred while fetching products!'),
//               ),
//             );
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Container(
//               child: Center(
//                 child: CupertinoActivityIndicator(),
//               ),
//             );
//           }
//           if (snapshot.data!.docs.isEmpty) {
//             return Container(
//               child: Center(
//                 child: Text('No products found!'),
//               ),
//             );
//           }

//           if (snapshot.data != null) {
//             return ListView.builder(
//               shrinkWrap: true,
//               physics: BouncingScrollPhysics(),
//               itemCount: snapshot.data!.docs.length,
//               itemBuilder: (context, index) {
//                 final data = snapshot.data!.docs[index];

//                 ProductModel productModel = ProductModel(
//                   productId: data['productId'],
//                   categoryId: data['categoryId'],
//                   productName: data['productName'],
//                   categoryName: data['categoryName'],
//                   salePrice: data['salePrice'],
//                   fullPrice: data['fullPrice'],
//                   productImages: data['productImages'],
//                   deliveryTime: data['deliveryTime'],
//                   isSale: data['isSale'],
//                   productDescription: data['productDescription'],
//                   createdAt: data['createdAt'],
//                   updatedAt: data['updatedAt'],
//                   quantity: data['quantity'],
//                   email: data['email'],
//                 );

//                 return SwipeActionCell(
//                   key: ObjectKey(productModel.productId),
//                   trailingActions: <SwipeAction>[
//                     SwipeAction(
//                         title: "Delete",
//                         onTap: (CompletionHandler handler) async {
//                           await Get.defaultDialog(
//                             title: "Delete Product",
//                             content: Text(
//                                 "Are you sure you want to delete this product?"),
//                             textCancel: "Cancel",
//                             textConfirm: "Delete",
//                             contentPadding: EdgeInsets.all(10.0),
//                             confirmTextColor: Colors.white,
//                             onCancel: () {},
//                             onConfirm: () async {
//                               Get.back(); // Close the dialog
//                               EasyLoading.show(status: 'Please wait..');

//                               await deleteImagesFromFirebase(
//                                 productModel.productImages,
//                               );

//                               await FirebaseFirestore.instance
//                                   .collection('products')
//                                   .doc(productModel.productId)
//                                   .delete();

//                               EasyLoading.dismiss();
//                             },
//                             buttonColor: Colors.red,
//                             cancelTextColor: Colors.black,
//                           );
//                         },
//                         color: Colors.red),
//                   ],
//                   child: Card(
//                     elevation: 5,
//                     child: ListTile(
//                       onTap: () {
//                         Get.to(() => SingleProductDetailScreen(
//                             productModel: productModel));
//                       },
//                       leading: CircleAvatar(
//                         backgroundColor: AppConstant.colorRed,
//                         backgroundImage: CachedNetworkImageProvider(
//                           productModel.productImages[0],
//                           errorListener: (err) {
//                             // Handle the error here
//                             print('Error loading image');
//                             Icon(Icons.error);
//                           },
//                         ),
//                       ),
//                       title: Text(productModel.productName),
//                       subtitle: Text(productModel.productId),
//                       trailing: GestureDetector(
//                           onTap: () {
//                             final editProdouctCategory =
//                                 Get.put(CategoryDropDownController());
//                             final isSaleController =
//                                 Get.put(IsSaleController());
//                             editProdouctCategory
//                                 .setOldValue(productModel.categoryId);

//                             isSaleController
//                                 .setIsSaleOldValue(productModel.isSale);
//                             Get.to(() =>
//                                 EditProductScreen(productModel: productModel));
//                           },
//                           child: Icon(Icons.edit)),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }

//           return Container();
//         },
//       ),
//       bottomNavigationBar: Theme(
//         data: Theme.of(context).copyWith(
//         // sets the background color of the `BottomNavigationBar`
//         canvasColor: AppColor().colorRed,
//         // sets the active color of the `BottomNavigationBar` if `Brightness` is light
//         primaryColor: Colors.red,
//         textTheme: Theme
//             .of(context)
//             .textTheme
//             .copyWith(bodySmall: TextStyle(color: Colors.yellow))),
//         child: BottomNavigationBar(
//             currentIndex: 0,
//             selectedItemColor: Colors.red,
//             unselectedItemColor: Colors.grey,
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.shopping_bag),
//                 label: 'Products',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.person),
//                 label: 'Users',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.category),
//                 label: 'Categories',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.account_circle),
//                 label: 'Profile',
//               ),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SellerHomeScreen()),
//                   );
//                   break;
//                 case 1:
//                   // Handle the Wishlist item tap
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => SellerAllProductScreen()));
//                   break;
//                 case 2:
//                   // Handle the Categories item tap
//                   Get.offAll(SellerAllUsersScreen());
//                   break;
//                 case 3:
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SellerCategoriesScreen()),
//                   );
//                   break;
//                 case 4:
//                   // Handle the Profile item tap
//                   Get.offAll(ProfileScreen());
//                   break;
//               }
//             },
//           ),
//       ),
//     );
//   }

//   Future<void> deleteImagesFromFirebase(List imagesUrls) async {
//     final FirebaseStorage storage = FirebaseStorage.instance;

//     for (String imageUrl in imagesUrls) {
//       try {
//         Reference reference = storage.refFromURL(imageUrl);

//         await reference.delete();
//       } catch (e) {
//         print("Error $e");
//       }
//     }
//   }

//   Future<void> _downloadProductsListAsPdf(BuildContext context) async {
//     try {
//       // Request storage permissions
//       if (!await _requestPermissions()) {
//         throw Exception('Storage permissions not granted');
//       }

//       final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
//       final products = querySnapshot.docs.map((doc) => doc.data()).toList();

//       // Create a PDF document
//       final pdf = pw.Document();

//       // Add a page to the PDF
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.ListView.builder(
//               itemCount: products.length,
//               itemBuilder: (context, index) {
//                 var product = products[index] as Map<String, dynamic>;
//                 return pw.Padding(
//                   padding: const pw.EdgeInsets.all(10),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('Product Name: ${product['productName']}'),
//                       pw.Text('Category: ${product['categoryName']}'),
//                       pw.Text('Sale Price: ${product['salePrice']}'),
//                       pw.Text('Full Price: ${product['fullPrice']}'),
//                       pw.Text('Delivery Time: ${product['deliveryTime']}'),
//                       pw.Text('Description: ${product['productDescription']}'),
//                       pw.Text('Quantity: ${product['quantity']}'),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       );

//       // Get the directory to save the file
//       final directory = Directory('/storage/emulated/0/Download');
//       if (!await directory.exists()) {
//         await directory.create(recursive: true);
//       }
//       final path = '${directory.path}/products.pdf';
//       final file = File(path);

//       // Write the PDF data to the file
//       await file.writeAsBytes(await pdf.save());

//       print("This is the path file: $file");

//       // Show a confirmation dialog
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Download Complete'),
//             content: Text('The product list has been saved to $path'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     } catch (e) {
//       print('Error during downloading process: $e');
//       _showErrorDialog(context, 'Failed to download product list: $e');
//     }
//   }

//   Future<bool> _requestPermissions() async {
//     final status = await Permission.storage.request();
//     if (status.isGranted) {
//       return true;
//     } else {
//       // Open app settings if permission is permanently denied
//       if (await Permission.storage.isPermanentlyDenied) {
//         await openAppSettings();
//       }
//       return false;
//     }
//   }

//   void _showErrorDialog(BuildContext context, String s) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(s),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class UserCard extends StatelessWidget {
//   final String userId;
//   final String name;
//   final String email;

//   const UserCard({
//     required this.userId,
//     required this.name,
//     required this.email,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserDetailScreen(userId: userId),
//           ),
//         );
//       },
//       child: Card(
//         margin: EdgeInsets.all(8.0),
//         child: ListTile(
//           title: Text(name),
//           subtitle: Text(email),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:admin_panel/controllers/category-dropdown_controller.dart';
import 'package:admin_panel/screens/add-products-screen.dart';
import 'package:admin_panel/screens/admin-profile.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/edit-product-screen.dart';
import 'package:admin_panel/screens/product-detail-screen.dart';
import 'package:admin_panel/screens/seller/profile.dart';
import 'package:admin_panel/screens/seller/seller-add-product.dart';
import 'package:admin_panel/screens/seller/seller-all-categories.dart';
import 'package:admin_panel/screens/seller/seller-all-user.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:admin_panel/screens/user-details-screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../const/app-colors.dart';
import '../../controllers/is-sale-controller.dart';
import '../../models/product-model.dart';
import '../../utils/AppConstant.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Get.offAll(AdminScreen());
          },
        ),
        title: Text("All Products", style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => AddProductScreen()),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
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
        backgroundColor: AppColor().colorRed,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            // .where('email', isEqualTo: user!.email) // Filter products by current user's email
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error occurred while fetching products!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found!'));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index];
              ProductModel productModel = ProductModel.fromMap(data.data() as Map<String, dynamic>);

              return SwipeActionCell(
                key: ObjectKey(productModel.productId),
                trailingActions: <SwipeAction>[
                  SwipeAction(
                      title: "Delete",
                      onTap: (CompletionHandler handler) async {
                        await Get.defaultDialog(
                          title: "Delete Product",
                          content: Text("Are you sure you want to delete this product?"),
                          textCancel: "Cancel",
                          textConfirm: "Delete",
                          contentPadding: EdgeInsets.all(10.0),
                          confirmTextColor: Colors.white,
                          onCancel: () {},
                          onConfirm: () async {
                            Get.back(); // Close the dialog
                            EasyLoading.show(status: 'Please wait..');

                            await deleteImagesFromFirebase(productModel.productImages[0]);

                            await FirebaseFirestore.instance
                                .collection('products')
                                .doc(productModel.productId)
                                .delete();

                            EasyLoading.dismiss();
                          },
                          buttonColor: Colors.red,
                          cancelTextColor: Colors.black,
                        );
                      },
                      color: Colors.red),
                ],
                child: Card(
                  elevation: 5,
                  child: ListTile(
                    onTap: () {
                      Get.to(() => SingleProductDetailScreen(productModel: productModel));
                    },
                    leading: CircleAvatar(
                      backgroundColor: AppConstant.colorRed,
                      backgroundImage: CachedNetworkImageProvider(
                        productModel.productImages[0],
                        errorListener: (err) {
                          print('Error loading image');
                          Icon(Icons.error);
                        },
                      ),
                    ),
                    title: Text(productModel.productName),
                    subtitle: Text(productModel.productId),
                    trailing: GestureDetector(
                      onTap: () {
                        final editProdouctCategory = Get.put(CategoryDropDownController());
                        final isSaleController = Get.put(IsSaleController());
                        editProdouctCategory.setOldValue(productModel.categoryId);
                        isSaleController.setIsSaleOldValue(productModel.isSale);
                        Get.to(() => EditProductScreen(productModel: productModel));
                      },
                      child: Icon(Icons.edit),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColor().colorRed,
          primaryColor: Colors.red,
          textTheme: Theme.of(context).textTheme.copyWith(bodySmall: TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
          currentIndex: 1, // Set the current index to 'Products'
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                break;
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllProductsScreen()));
                break;
              case 2:
                Get.offAll(AllUsersScreen());
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllCategoriesScreen()));
                break;
              case 4:
                Get.offAll(AdminProfileScreen());
                break;
            }
          },
        ),
      ),
    );
  }

  Future<void> deleteImagesFromFirebase(List<String> imagesUrls) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    for (String imageUrl in imagesUrls) {
      try {
        Reference reference = storage.refFromURL(imageUrl);
        await reference.delete();
      } catch (e) {
        print("Error $e");
      }
    }
  }

  Future<void> _downloadProductsListAsPdf(BuildContext context) async {
    try {
      if (!await _requestPermissions()) {
        throw Exception('Storage permissions not granted');
      }

      final querySnapshot = await FirebaseFirestore.instance.collection('products').where('email', isEqualTo: user!.email).get();
      final products = querySnapshot.docs.map((doc) => doc.data()).toList();

      final pdf = pw.Document();

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

      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final path = '${directory.path}/products.pdf';
      final file = File(path);

      await file.writeAsBytes(await pdf.save());

      print("This is the path file: $file");

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
