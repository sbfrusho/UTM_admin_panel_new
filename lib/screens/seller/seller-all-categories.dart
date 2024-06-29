import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/models/categories_model.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/edit-category.dart';
import 'package:admin_panel/screens/seller/Seller-all-product.dart';
import 'package:admin_panel/screens/seller/profile.dart';
import 'package:admin_panel/screens/seller/seller-all-user.dart';
import 'package:admin_panel/screens/seller/seller-edit-category.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:admin_panel/utils/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';

import '../add_category_screen.dart';

class SellerCategoriesScreen extends StatelessWidget {
  const SellerCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: const Text(
          "All Categories",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Get.offAll(SellerHomeScreen());
          },
        ),
        actions: [
          InkWell(
            onTap: () => Get.to(() => const AddCategoriesScreen()),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              // child: Icon(
              //   Icons.add,
              //   color: Colors.white,
              // ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: const Center(
                child: Text('Error occurred while fetching category!'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Container(
              child: const Center(
                child: Text('No category found!'),
              ),
            );
          }

          if (snapshot.data != null) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];

                CategoriesModel categoriesModel = CategoriesModel(
                  categoryId: data['categoryId'],
                  categoryName: data['categoryName'],
                  categoryImg: data['categoryImg'],
                  createdAt: data['createdAt'],
                  updatedAt: data['updatedAt'],
                );

                return SwipeActionCell(
                  key: ObjectKey(categoriesModel.categoryId),
                  trailingActions: <SwipeAction>[
                    SwipeAction(
                      title: "Delete",
                      onTap: (CompletionHandler handler) async {
                        await Get.defaultDialog(
                          title: "Delete Category",
                          content: const Text(
                              "Are you sure you want to delete this category?"),
                          textCancel: "Cancel",
                          textConfirm: "Delete",
                          contentPadding: const EdgeInsets.all(10.0),
                          confirmTextColor: Colors.white,
                          onCancel: () {},
                          onConfirm: () async {
                            Get.back(); // Close the dialog
                            EasyLoading.show(status: 'Please wait..');

                            // Deleting the category image from Firebase Storage
                            // You can create a helper function to handle this part
                            try {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(categoriesModel.categoryId)
                                  .delete();
                              EasyLoading.dismiss();
                            } catch (e) {
                              EasyLoading.dismiss();
                              print('Error deleting category: $e');
                            }
                          },
                          buttonColor: Colors.red,
                          cancelTextColor: Colors.black,
                        );
                      },
                      color: Colors.red,
                    ),
                  ],
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      onTap: () {},
                      leading: CircleAvatar(
                        backgroundColor: AppColor().colorRed,
                        backgroundImage: CachedNetworkImageProvider(
                          categoriesModel.categoryImg.toString(),
                          
                        ),
                      ),
                      title: Text(categoriesModel.categoryName),
                      subtitle: Text(categoriesModel.categoryId),
                      trailing: GestureDetector(
                        onTap: () {
                          Get.offAll(SellerEditCategoryScreen(
                              categoriesModel: categoriesModel));
                        },
                        child: const Icon(Icons.edit),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Container();
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: AppColor().colorRed,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.red,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(bodySmall: TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
          currentIndex: 0,
          // selectedItemColor: Colors.red,
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SellerAllProductScreen()));
                break;
              case 2:
                Get.offAll(SellerAllUsersScreen());
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SellerCategoriesScreen()),
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
}
