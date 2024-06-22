// ignore_for_file: must_be_immutable, file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:admin_panel/models/order-model.dart';
import 'package:admin_panel/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckSingleOrderScreen extends StatelessWidget {
  String docId;
  OrderModel orderModel;
  CheckSingleOrderScreen({
    super.key,
    required this.docId,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.colorRed,
        title: Text('Order'),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(docId).collection('items').doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Order not found'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.productName),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.productTotalPrice.toString()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('x' + orderModel.productQuantity.toString()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.productDescription),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    foregroundImage: NetworkImage(orderModel.productImages[0]),
                  ),
                  CircleAvatar(
                    radius: 50.0,
                    foregroundImage: NetworkImage(orderModel.productImages[1]),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.customerName),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.customerPhone),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.customerAddress),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(orderModel.customerId),
              ),
            ],
          );
        },
      ),
    );
  }
}
