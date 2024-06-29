import 'dart:io';
import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/models/product-model.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/seller/Seller-all-product.dart';
import 'package:admin_panel/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../controllers/category-dropdown_controller.dart';
import '../../controllers/is-sale-controller.dart';
import '../../controllers/products-images-controller.dart';
import '../../services/generate-ids-service.dart';
import '../../widgets/dropdown-categories-widget.dart';

class SellerAddProductScreen extends StatefulWidget {
  SellerAddProductScreen({super.key});

  @override
  _SellerAddProductScreenState createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  AddProductImagesController addProductImagesController =
      Get.put(AddProductImagesController());

  CategoryDropDownController categoryDropDownController =
      Get.put(CategoryDropDownController());

  IsSaleController isSaleController = Get.put(IsSaleController());

  TextEditingController productNameController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController fullPriceController = TextEditingController();
  TextEditingController deliveryTimeController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  List<String> availableSizes = ["S", "M", "L", "XL"];
  List<String> selectedSizes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Products"),
        backgroundColor: AppColor().colorRed,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Get.offAll(SellerAllProductScreen());
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Select Images"),
                    ElevatedButton(
                      onPressed: () {
                        addProductImagesController.showImagesPickerDialog();
                      },
                      child: Text("Select Images"),
                    )
                  ],
                ),
              ),

              // Show selected images
              GetBuilder<AddProductImagesController>(
                init: AddProductImagesController(),
                builder: (imageController) {
                  return imageController.selectedIamges.length > 0
                      ? Container(
                          width: MediaQuery.of(context).size.width - 20,
                          height: Get.height / 3.0,
                          child: GridView.builder(
                            itemCount: imageController.selectedIamges.length,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 10,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                children: [
                                  Image.file(
                                    File(addProductImagesController
                                        .selectedIamges[index].path),
                                    fit: BoxFit.cover,
                                    height: Get.height / 4,
                                    width: Get.width / 2,
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () {
                                        imageController.removeImages(index);
                                        print(imageController
                                            .selectedIamges.length);
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: AppConstant.colorRed,
                                        child: Icon(
                                          Icons.close,
                                          color: AppConstant.colorWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),

              // Show categories dropdown
              DropDownCategoriesWiidget(),

              // Show 'Is Sale' toggle
              GetBuilder<IsSaleController>(
                init: IsSaleController(),
                builder: (isSaleController) {
                  return Card(
                    elevation: 10,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Is Sale"),
                          Switch(
                            value: isSaleController.isSale.value,
                            activeColor: AppConstant.colorRed,
                            onChanged: (value) {
                              isSaleController.toggleIsSale(value);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Product details form
              SizedBox(height: 10.0),
              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  cursorColor: AppConstant.colorWhite,
                  textInputAction: TextInputAction.next,
                  controller: productNameController,
                  decoration: InputDecoration(
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
              SizedBox(height: 10.0),

              Obx(() {
                return isSaleController.isSale.value
                    ? Container(
                        height: 65,
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          cursorColor: AppConstant.colorRed,
                          textInputAction: TextInputAction.next,
                          controller: salePriceController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            hintText: "Sale Price",
                            hintStyle: TextStyle(fontSize: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              }),

              SizedBox(height: 10.0),
              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  cursorColor: AppConstant.colorRed,
                  textInputAction: TextInputAction.next,
                  controller: fullPriceController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    hintText: "Full Price",
                    hintStyle: TextStyle(fontSize: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0),
              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  cursorColor: AppConstant.colorRed,
                  textInputAction: TextInputAction.next,
                  controller: deliveryTimeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    hintText: "Delivery Time",
                    hintStyle: TextStyle(fontSize: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0),
              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  cursorColor: AppConstant.colorRed,
                  textInputAction: TextInputAction.next,
                  controller: productDescriptionController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    hintText: "Product Desc",
                    hintStyle: TextStyle(fontSize: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  cursorColor: AppConstant.colorRed,
                  textInputAction: TextInputAction.next,
                  controller: quantityController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    hintText: "Quantity",
                    hintStyle: TextStyle(fontSize: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),

              // Select sizes checkboxes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Sizes"),
                    Wrap(
                      children: availableSizes.map((size) {
                        return CheckboxListTile(
                          title: Text(size),
                          value: selectedSizes.contains(size),
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                if (value) {
                                  selectedSizes.add(size); // Add size if checked
                                } else {
                                  selectedSizes.remove(size); // Remove size if unchecked
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Upload button
              ElevatedButton(
                onPressed: () async {
                  try {
                    EasyLoading.show();

                    // Upload selected images
                    await addProductImagesController.uploadFunction(
                        addProductImagesController.selectedIamges);
                    print(addProductImagesController.arrImagesUrl);

                    // Generate product ID
                    String productId =
                        await GenerateIds().generateProductId();

                    // Create ProductModel object
                    ProductModel productModel = ProductModel(
                      productId: productId,
                      categoryId:
                          categoryDropDownController.selectedCategoryId
                              .toString(),
                      productName: productNameController.text.trim(),
                      categoryName: categoryDropDownController
                          .selectedCategoryName
                          .toString(),
                      salePrice: salePriceController.text.isNotEmpty
                          ? salePriceController.text.trim()
                          : '',
                      fullPrice: fullPriceController.text.trim(),
                      productImages:
                          addProductImagesController.arrImagesUrl,
                      deliveryTime: deliveryTimeController.text.trim(),
                      isSale: isSaleController.isSale.value,
                      productDescription:
                          productDescriptionController.text.trim(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      quantity: quantityController.text.trim(),
                      email: user!.email.toString(),
                      productSizes: selectedSizes,
                    );

                    // Save product data to Firestore
                    await FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .set(productModel.toMap());

                    // Clear text fields and dismiss loading indicator
                    productNameController.clear();
                    salePriceController.clear();
                    fullPriceController.clear();
                    deliveryTimeController.clear();
                    productDescriptionController.clear();
                    EasyLoading.dismiss();

                    // Navigate to SellerAllProductScreen after successful upload
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerAllProductScreen(),
                      ),
                    );
                  } catch (e) {
                    print("Error: $e");
                  }
                },
                child: Text("Upload"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColor().colorRed,
          primaryColor: Colors.red,
          textTheme: Theme.of(context)
              .textTheme
              .copyWith(bodySmall: TextStyle(color: Colors.yellow)),
        ),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllProductsScreen()));
                break;
              case 2:
                Get.offAll(AllUsersScreen());
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AllCategoriesScreen()),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
