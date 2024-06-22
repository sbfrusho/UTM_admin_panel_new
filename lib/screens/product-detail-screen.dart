// ignore_for_file: prefer_const_constructors, file_names, must_be_immutable, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/models/product-model.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingleProductDetailScreen extends StatelessWidget {
  ProductModel productModel;
  SingleProductDetailScreen({
    super.key,
    required this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text(productModel.productName , style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Product Name"),
                        Container(
                          width: Get.width / 2,
                          child: Text(
                            productModel.productName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Product Price"),
                        Container(
                          width: Get.width / 2,
                          child: Text(
                            productModel.salePrice != ''
                                ? productModel.salePrice
                                : productModel.fullPrice,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Quantity"),
                        Container(
                          width: Get.width / 2,
                          child: Text(
                            productModel.quantity.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Delivery Time"),
                        Container(
                          width: Get.width / 2,
                          child: Text(
                            productModel.deliveryTime,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Is Sale?"),
                        Container(
                          width: Get.width / 2,
                          child: Text(
                            productModel.isSale ? "True" : "false",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                icon: Icon(Icons.person),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Categories',
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
}
