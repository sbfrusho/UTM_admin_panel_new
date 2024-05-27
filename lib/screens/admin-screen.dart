// // ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers

// import 'package:admin_panel/utils/constant.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/get-all-user-length-controller.dart';
// import '../models/user-model.dart';
// import '../widgets/drawer-widget-admin.dart';

// class AdminScreen extends StatefulWidget {
//   const AdminScreen({super.key});

//   @override
//   State<AdminScreen> createState() => _AdminScreenState();
// }

// class _AdminScreenState extends State<AdminScreen> {
//   final GetUserLengthController _getUserLengthController =
//       Get.put(GetUserLengthController());
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() {
//           return Text(
//               'Users (${_getUserLengthController.userCollectionLength.toString()})');
//         }),
//         backgroundColor: AppConstant.colorRed,
//       ),
//       drawer: DrawerAdminWidget(),
//       body: FutureBuilder(
//         future: FirebaseFirestore.instance
//             .collection('users')
//             .orderBy('createdOn', descending: true)
//             .get(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Container(
//               child: Center(
//                 child: Text('Error occurred while fetching category!'),
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
//                 child: Text('No users found!'),
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

//                 UserModel userModel = UserModel(
//                   uId: data['uId'],
//                   username: data['username'],
//                   email: data['email'],
//                   phone: data['phone'],
//                   userImg: data['userImg'],
//                   userDeviceToken: data['userDeviceToken'],
//                   country: data['country'],
//                   userAddress: data['userAddress'],
//                   street: data['street'],
//                   isAdmin: data['isAdmin'],
//                   isActive: data['isActive'],
//                   createdOn: data['createdOn'],
//                 );

//                 return Card(
//                   elevation: 5,
//                   child: ListTile(
//                     // onTap: () => Get.to(
//                     //   () => SpecificCustomerOrderScreen(
//                     //       docId: snapshot.data!.docs[index]['uId'],
//                     //       customerName: snapshot.data!.docs[index]
//                     //           ['customerName']),
//                     // ),

//                     leading: CircleAvatar(
//                       backgroundColor: AppConstant.colorRed,
//                       backgroundImage: CachedNetworkImageProvider(
//                         userModel.userImg,
//                         errorListener: (err) {
//                           // Handle the error here
//                           print('Error loading image');
//                           Icon(Icons.error);
//                         },
//                       ),
//                     ),
//                     title: Text(userModel.username),
//                     subtitle: Text(userModel.email),
//                     trailing: Icon(Icons.edit),
//                   ),
//                 );
//               },
//             );
//           }

//           return Container();
//         },
//       ),
//     );
//   }
// }
import 'package:admin_panel/screens/all-products-screen.dart';
import 'package:admin_panel/screens/all-users-screen.dart';
import 'package:admin_panel/widgets/drawer-widget-admin.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.red, // Choose your preferred color
      ),
      drawer: DrawerAdminWidget(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200], // Background color for products section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.all(16),
                  //   child: Text(
                  //     'Products',
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  Divider(color: Colors.black,),
                  Expanded(
                    child: AllProductsScreen(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[300], // Background color for users section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.all(16),
                  //   child: Text(
                  //     'Users',
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: AllUsersScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add product/user action
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Choose your preferred color
      ),
    );
  }
}