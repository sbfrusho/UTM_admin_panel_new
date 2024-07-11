// import 'dart:io';
// import 'package:admin_panel/const/app-colors.dart';
// import 'package:admin_panel/controllers/edit-product-controller.dart';
// import 'package:admin_panel/models/product-model.dart';
// import 'package:admin_panel/screens/admin-screen.dart';
// import 'package:admin_panel/screens/all-products-screen.dart';
// import 'package:admin_panel/screens/all-users-screen.dart';
// import 'package:admin_panel/screens/all_categories_screen.dart';
// import 'package:admin_panel/screens/seller/Seller-all-product.dart'; // Make sure to import the screen
// import 'package:admin_panel/screens/seller/seller-all-categories.dart';
// import 'package:admin_panel/screens/seller/seller-home-screen.dart';
// import 'package:admin_panel/utils/constant.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import '../../controllers/category-dropdown_controller.dart';
// import '../../controllers/is-sale-controller.dart';

// class SellerEditProductScreen extends StatefulWidget {
//   final ProductModel productModel;

//   SellerEditProductScreen({Key? key, required this.productModel}) : super(key: key);

//   @override
//   State<SellerEditProductScreen> createState() => _SellerEditProductScreenState();
// }

// class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
//   final IsSaleController isSaleController = Get.put(IsSaleController());
//   final CategoryDropDownController categoryDropDownController = Get.put(CategoryDropDownController());
//   final TextEditingController productNameController = TextEditingController();
//   final TextEditingController salePriceController = TextEditingController();
//   final TextEditingController fullPriceController = TextEditingController();
//   final TextEditingController deliveryTimeController = TextEditingController();
//   final TextEditingController productDescriptionController = TextEditingController();
//   final TextEditingController quantityController = TextEditingController();
//   final User? user = FirebaseAuth.instance.currentUser;

//   final List<String> availableSizes = ["S", "M", "L", "XL"];
//   final List<String> selectedSizes = [];

//   @override
//   void initState() {
//     super.initState();
//     productNameController.text = widget.productModel.productName;
//     salePriceController.text = widget.productModel.salePrice;
//     fullPriceController.text = widget.productModel.fullPrice;
//     deliveryTimeController.text = widget.productModel.deliveryTime;
//     productDescriptionController.text = widget.productModel.productDescription;
//     quantityController.text = widget.productModel.quantity;
//     selectedSizes.addAll(widget.productModel.productSizes);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<EditProductController>(
//       init: EditProductController(productModel: widget.productModel),
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: AppColor().colorRed,
//             title: Text(widget.productModel.productName.split(' ').first, style: TextStyle(color: Colors.white)),
//             leading: IconButton(
//               icon: Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//           body: SingleChildScrollView(
//             child: Container(
//               child: Column(
//                 children: [
//                   SingleChildScrollView(
//                     child: Container(
//                       width: MediaQuery.of(context).size.width - 20,
//                       height: Get.height / 4.0,
//                       child: GridView.builder(
//                         itemCount: controller.images.length,
//                         physics: const BouncingScrollPhysics(),
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 2,
//                           crossAxisSpacing: 2,
//                         ),
//                         itemBuilder: (BuildContext context, int index) {
//                           return Stack(
//                             children: [
//                               CachedNetworkImage(
//                                 imageUrl: controller.images[index],
//                                 fit: BoxFit.contain,
//                                 height: Get.height / 5.5,
//                                 width: Get.width / 2,
//                                 placeholder: (context, url) => Center(child: CupertinoActivityIndicator()),
//                                 errorWidget: (context, url, error) => Icon(Icons.error),
//                               ),
//                               Positioned(
//                                 right: 10,
//                                 top: 0,
//                                 child: InkWell(
//                                   onTap: () async {
//                                     EasyLoading.show();
//                                     await controller.deleteImagesFromStorage(controller.images[index].toString());
//                                     await controller.deleteImageFromFireStore(controller.images[index].toString(), widget.productModel.productId);
//                                     EasyLoading.dismiss();
//                                   },
//                                   child: CircleAvatar(
//                                     backgroundColor: AppConstant.colorRed,
//                                     child: Icon(
//                                       Icons.close,
//                                       color: AppConstant.colorWhite,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                   // Drop down
//                   GetBuilder<CategoryDropDownController>(
//                     init: CategoryDropDownController(),
//                     builder: (categoriesDropDownController) {
//                       return Column(
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 0.0),
//                             child: Card(
//                               elevation: 10,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: DropdownButton<String>(
//                                   value: categoriesDropDownController.selectedCategoryId?.value,
//                                   items: categoriesDropDownController.categories.map((category) {
//                                     return DropdownMenuItem<String>(
//                                       value: category['categoryId'],
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         children: [
//                                           CircleAvatar(
//                                             backgroundImage: NetworkImage(category['categoryImg'].toString()),
//                                           ),
//                                           const SizedBox(width: 20),
//                                           Text(category['categoryName']),
//                                         ],
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged: (String? selectedValue) async {
//                                     categoriesDropDownController.setSelectedCategory(selectedValue);
//                                     String? categoryName = await categoriesDropDownController.getCategoryName(selectedValue);
//                                     categoriesDropDownController.setSelectedCategoryName(categoryName);
//                                   },
//                                   hint: const Text(
//                                     'Select a category',
//                                   ),
//                                   isExpanded: true,
//                                   elevation: 10,
//                                   underline: const SizedBox.shrink(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),

//                   // Is Sale
//                   GetBuilder<IsSaleController>(
//                     init: IsSaleController(),
//                     builder: (isSaleController) {
//                       return Card(
//                         elevation: 10,
//                         child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Is Sale"),
//                               Switch(
//                                 value: isSaleController.isSale.value,
//                                 activeColor: AppConstant.colorRed,
//                                 onChanged: (value) {
//                                   isSaleController.toggleIsSale(value);
//                                 },
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),

//                   // Form fields
//                   SizedBox(height: 10.0),
//                   Container(
//                     height: 65,
//                     margin: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: TextFormField(
//                       cursorColor: AppConstant.colorRed,
//                       textInputAction: TextInputAction.next,
//                       controller: productNameController,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                         hintText: "Product Name",
//                         hintStyle: TextStyle(fontSize: 12.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                         ),
//                       ),
//                     ),
//                   ),

//                   GetBuilder<IsSaleController>(
//                     init: IsSaleController(),
//                     builder: (isSaleController) {
//                       return isSaleController.isSale.value
//                           ? Container(
//                               height: 65,
//                               margin: EdgeInsets.symmetric(horizontal: 10.0),
//                               child: TextFormField(
//                                 cursorColor: AppConstant.colorRed,
//                                 textInputAction: TextInputAction.next,
//                                 controller: salePriceController,
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                                   hintText: "Sale Price",
//                                   hintStyle: TextStyle(fontSize: 12.0),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : SizedBox.shrink();
//                     },
//                   ),

//                   SizedBox(height: 10.0),
//                   Container(
//                     height: 65,
//                     margin: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: TextFormField(
//                       cursorColor: AppConstant.colorRed,
//                       textInputAction: TextInputAction.next,
//                       controller: fullPriceController,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                         hintText: "Full Price",
//                         hintStyle: TextStyle(fontSize: 12.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 10.0),
//                   Container(
//                     height: 65,
//                     margin: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: TextFormField(
//                       cursorColor: AppConstant.colorRed,
//                       textInputAction: TextInputAction.next,
//                       controller: deliveryTimeController,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                         hintText: "Delivery Time",
//                         hintStyle: TextStyle(fontSize: 12.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 10.0),
//                   Container(
//                     height: 65,
//                     margin: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: TextFormField(
//                       cursorColor: AppConstant.colorRed,
//                       textInputAction: TextInputAction.next,
//                       controller: productDescriptionController,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                         hintText: "Product Desc",
//                         hintStyle: TextStyle(fontSize: 12.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 10.0),
//                   Container(
//                     height: 65,
//                     margin: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: TextFormField(
//                       cursorColor: AppConstant.colorRed,
//                       textInputAction: TextInputAction.next,
//                       controller: quantityController,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                         hintText: "Quantity",
//                         hintStyle: TextStyle(fontSize: 12.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Sizes
//                   Card(
//                     elevation: 10,
//                     margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Sizes Available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                           SizedBox(height: 10),
//                           Wrap(
//                             spacing: 10.0,
//                             children: availableSizes.map((size) {
//                               return FilterChip(
//                                 selected: selectedSizes.contains(size),
//                                 label: Text(size),
//                                 onSelected: (bool selected) {
//                                   setState(() {
//                                     if (selected) {
//                                       selectedSizes.add(size);
//                                     } else {
//                                       selectedSizes.remove(size);
//                                     }
//                                   });
//                                 },
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Update button
//                   ElevatedButton(
//                     onPressed: () async {
//                       EasyLoading.show();
//                       ProductModel newProductModel = ProductModel(
//                         productId: widget.productModel.productId,
//                         categoryId: categoryDropDownController.selectedCategoryId.toString(),
//                         productName: productNameController.text.trim(),
//                         categoryName: categoryDropDownController.selectedCategoryName.toString(),
//                         salePrice: salePriceController.text.trim(),
//                         fullPrice: fullPriceController.text.trim(),
//                         productImages: widget.productModel.productImages,
//                         deliveryTime: deliveryTimeController.text.trim(),
//                         isSale: isSaleController.isSale.value,
//                         productDescription: productDescriptionController.text.trim(),
//                         createdAt: widget.productModel.createdAt,
//                         updatedAt: DateTime.now(),
//                         quantity: quantityController.text.trim(),
//                         email: user!.email.toString(),
//                         productSizes: selectedSizes, // Update with selected sizes
//                       );
//                       print('Updated Product Sizes: $selectedSizes');

//                       await FirebaseFirestore.instance.collection('products').doc(widget.productModel.productId).update(newProductModel.toMap());

//                       EasyLoading.dismiss();
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => SellerAllProductScreen()),
//                       );
//                     },
//                     child: Text("Update"),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           bottomNavigationBar: Theme(
//             data: Theme.of(context).copyWith(
//               canvasColor: AppColor().colorRed,
//               primaryColor: Colors.red,
//               textTheme: Theme.of(context).textTheme.copyWith(
//                     bodySmall: TextStyle(color: Colors.yellow),
//                   ),
//             ),
//             child: BottomNavigationBar(
//               currentIndex: 0,
//               selectedItemColor: Colors.red,
//               unselectedItemColor: Colors.grey,
//               items: const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.shopping_bag),
//                   label: 'Products',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.category),
//                   label: 'Categories',
//                 ),
//               ],
//               onTap: (index) {
//                 switch (index) {
//                   case 0:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SellerHomeScreen()),
//                     );
//                     break;
//                   case 1:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SellerAllProductScreen()),
//                     );
//                     break;
//                   case 3:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SellerCategoriesScreen()),
//                     );
//                     break;
//                 }
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:io';
import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/controllers/edit-product-controller.dart';
import 'package:admin_panel/models/product-model.dart';
import 'package:admin_panel/screens/admin-screen.dart';
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/screens/all_categories_screen.dart';
import 'package:admin_panel/screens/seller/Seller-all-product.dart'; // Make sure to import the screen
import 'package:admin_panel/screens/seller/seller-all-categories.dart';
import 'package:admin_panel/screens/seller/seller-home-screen.dart';
import 'package:admin_panel/utils/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../controllers/category-dropdown_controller.dart';
import '../../controllers/is-sale-controller.dart';

class SellerEditProductScreen extends StatefulWidget {
  final ProductModel productModel;

  SellerEditProductScreen({Key? key, required this.productModel}) : super(key: key);

  @override
  State<SellerEditProductScreen> createState() => _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
  final IsSaleController isSaleController = Get.put(IsSaleController());
  final CategoryDropDownController categoryDropDownController = Get.put(CategoryDropDownController());
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController fullPriceController = TextEditingController();
  final TextEditingController deliveryTimeController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  final List<String> availableSizes = ["S", "M", "L", "XL"];
  final List<String> selectedSizes = [];

  @override
  void initState() {
    super.initState();
    productNameController.text = widget.productModel.productName;
    salePriceController.text = widget.productModel.salePrice;
    fullPriceController.text = widget.productModel.fullPrice;
    deliveryTimeController.text = widget.productModel.deliveryTime;
    productDescriptionController.text = widget.productModel.productDescription;
    quantityController.text = widget.productModel.quantity;
    selectedSizes.addAll(widget.productModel.productSizes);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProductController>(
      init: EditProductController(productModel: widget.productModel),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor().colorRed,
            title: Text(widget.productModel.productName.split(' ').first, style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await _deleteProduct();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 20,
                      height: Get.height / 4.0,
                      child: GridView.builder(
                        itemCount: controller.images.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: controller.images[index],
                                fit: BoxFit.contain,
                                height: Get.height / 5.5,
                                width: Get.width / 2,
                                placeholder: (context, url) => Center(child: CupertinoActivityIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              Positioned(
                                right: 10,
                                top: 0,
                                child: InkWell(
                                  onTap: () async {
                                    EasyLoading.show();
                                    await controller.deleteImagesFromStorage(controller.images[index].toString());
                                    await controller.deleteImageFromFireStore(controller.images[index].toString(), widget.productModel.productId);
                                    EasyLoading.dismiss();
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
                    ),
                  ),

                  // Drop down
                  GetBuilder<CategoryDropDownController>(
                    init: CategoryDropDownController(),
                    builder: (categoriesDropDownController) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Card(
                              elevation: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  value: categoriesDropDownController.selectedCategoryId?.value,
                                  items: categoriesDropDownController.categories.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category['categoryId'],
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(category['categoryImg'].toString()),
                                          ),
                                          const SizedBox(width: 20),
                                          Text(category['categoryName']),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? selectedValue) async {
                                    categoriesDropDownController.setSelectedCategory(selectedValue);
                                    String? categoryName = await categoriesDropDownController.getCategoryName(selectedValue);
                                    categoriesDropDownController.setSelectedCategoryName(categoryName);
                                  },
                                  hint: const Text(
                                    'Select a category',
                                  ),
                                  isExpanded: true,
                                  elevation: 10,
                                  underline: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Is Sale
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

                  // Form fields
                  SizedBox(height: 10.0),
                  Container(
                    height: 65,
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      cursorColor: AppConstant.colorRed,
                      textInputAction: TextInputAction.next,
                      controller: productNameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        hintText: "Product Name",
                        hintStyle: TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),

                  GetBuilder<IsSaleController>(
                    init: IsSaleController(),
                    builder: (isSaleController) {
                      return isSaleController.isSale.value
                          ? Container(
                              height: 65,
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              child: TextFormField(
                                cursorColor: AppConstant.colorRed,
                                textInputAction: TextInputAction.next,
                                controller: salePriceController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                  hintText: "Sale Price",
                                  hintStyle: TextStyle(fontSize: 12.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),

                  SizedBox(height: 10.0),
                  Container(
                    height: 65,
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      cursorColor: AppConstant.colorRed,
                      textInputAction: TextInputAction.next,
                      controller: fullPriceController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        hintText: "Full Price",
                        hintStyle: TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        hintText: "Delivery Time",
                        hintStyle: TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        hintText: "Product Desc",
                        hintStyle: TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        hintText: "Quantity",
                        hintStyle: TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),

                  // Sizes
                  Card(
                    elevation: 10,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sizes Available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10.0,
                            children: availableSizes.map((size) {
                              return FilterChip(
                                selected: selectedSizes.contains(size),
                                label: Text(size),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedSizes.add(size);
                                    } else {
                                      selectedSizes.remove(size);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Update button
                  ElevatedButton(
                    onPressed: () async {
                      EasyLoading.show();
                      ProductModel newProductModel = ProductModel(
                        productId: widget.productModel.productId,
                        categoryId: categoryDropDownController.selectedCategoryId.toString(),
                        productName: productNameController.text.trim(),
                        categoryName: categoryDropDownController.selectedCategoryName.toString(),
                        salePrice: salePriceController.text.trim(),
                        fullPrice: fullPriceController.text.trim(),
                        productImages: widget.productModel.productImages,
                        deliveryTime: deliveryTimeController.text.trim(),
                        isSale: isSaleController.isSale.value,
                        productDescription: productDescriptionController.text.trim(),
                        createdAt: widget.productModel.createdAt,
                        updatedAt: DateTime.now(),
                        quantity: quantityController.text.trim(),
                        email: user!.email.toString(),
                        productSizes: selectedSizes, // Update with selected sizes
                      );
                      print('Updated Product Sizes: $selectedSizes');

                      await FirebaseFirestore.instance.collection('products').doc(widget.productModel.productId).update(newProductModel.toMap());

                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SellerAllProductScreen()),
                      );
                    },
                    child: Text("Update"),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColor().colorRed,
              primaryColor: Colors.red,
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodySmall: TextStyle(color: Colors.yellow),
                  ),
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
                  icon: Icon(Icons.category),
                  label: 'Categories',
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
                      MaterialPageRoute(builder: (context) => SellerAllProductScreen()),
                    );
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SellerCategoriesScreen()),
                    );
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct() async {
  EasyLoading.show();
  try {
    // Fetch all orders
    QuerySnapshot orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();

    for (QueryDocumentSnapshot orderDoc in orderSnapshot.docs) {
      // Fetch all items in the order
      QuerySnapshot itemsSnapshot = await orderDoc.reference.collection('items').get();

      for (QueryDocumentSnapshot itemDoc in itemsSnapshot.docs) {
        // Check if the item is the product to be deleted
        if (itemDoc['product_id'] == widget.productModel.productId) {
          // Delete the item from the subcollection
          await itemDoc.reference.delete();
        }
      }
    }

    // Delete the product from the products collection
    await FirebaseFirestore.instance.collection('products').doc(widget.productModel.productId).delete();

    EasyLoading.dismiss();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SellerAllProductScreen()),
    );
  } catch (e) {
    EasyLoading.dismiss();
    Get.snackbar('Error', 'Failed to delete product: $e', snackPosition: SnackPosition.BOTTOM);
  }
}

}
