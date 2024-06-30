// ignore_for_file: must_be_immutable, avoid_unnecessary_containers

import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/controllers/edit-category.dart';
import 'package:admin_panel/models/categories_model.dart';
import 'package:admin_panel/screens/seller/Seller-all-product.dart';
import 'package:admin_panel/screens/seller/profile.dart';
import 'package:admin_panel/screens/seller/seller-all-categories.dart';
import 'package:admin_panel/screens/seller/seller-all-user.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SellerEditCategoryScreen extends StatefulWidget {
  CategoriesModel categoriesModel;
  SellerEditCategoryScreen({super.key, required this.categoriesModel});

  @override
  State<SellerEditCategoryScreen> createState() => _SellerEditCategoryScreenState();
}

class _SellerEditCategoryScreenState extends State<SellerEditCategoryScreen> {
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    categoryNameController.text = widget.categoriesModel.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text(widget.categoriesModel.categoryName , style: TextStyle(color: Colors.white),),
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          Get.offAll(SellerCategoriesScreen());
        },),
        
      ),
      body: Container(
        child: Column(
          children: [
            GetBuilder(
              init: EditCategoryController(
                  categoriesModel: widget.categoriesModel),
              builder: (editCategory) {
                return editCategory.categoryImg.value != ''
                    ? Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: editCategory.categoryImg.value.toString(),
                            fit: BoxFit.contain,
                            height: Get.height / 5.5,
                            width: Get.width / 2,
                            placeholder: (context, url) => const Center(
                                child: CupertinoActivityIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          Positioned(
                            right: 10,
                            top: 0,
                            child: InkWell(
                              onTap: () async {
                                EasyLoading.show();
                                await editCategory.deleteImagesFromStorage(
                                    editCategory.categoryImg.value.toString());
                                await editCategory.deleteImageFromFireStore(
                                    editCategory.categoryImg.value.toString(),
                                    widget.categoriesModel.categoryId);
                                EasyLoading.dismiss();
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),

            //
            const SizedBox(height: 10.0),
            Container(
              height: 65,
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                controller: categoryNameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  hintText: "Product Name",
                  hintStyle: TextStyle(fontSize: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                EasyLoading.show();
                CategoriesModel categoriesModel = CategoriesModel(
                  categoryId: widget.categoriesModel.categoryId,
                  categoryName: categoryNameController.text.trim(),
                  categoryImg: widget.categoriesModel.categoryImg,
                  createdAt: widget.categoriesModel.createdAt,
                  updatedAt: DateTime.now(),
                );

                await FirebaseFirestore.instance
                    .collection('categories')
                    .doc(categoriesModel.categoryId)
                    .update(categoriesModel.toJson());

                

                EasyLoading.dismiss();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerCategoriesScreen()),
                );
              },
              child: const Text("Update"),
            )
          ],
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
                icon: Icon(Icons.category),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.man),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerCategoriesScreen()),
                  );
                  break;
                case 3:
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