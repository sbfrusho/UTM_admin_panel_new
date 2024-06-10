import 'package:admin_panel/const/app-colors.dart';
import 'package:admin_panel/models/order-model.dart';
import 'package:admin_panel/screens/all-orders-screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order-service.dart';
import '../models/order-items-model.dart';

class OrderItemsScreen extends StatelessWidget {
  final String orderId;
  final OrderService orderService = OrderService();

  OrderItemsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Items',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColor().colorRed,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(AllOrdersScreen());
          },),
      ),
      body: FutureBuilder<List<OrderItemModel>>(
        future: orderService.getOrderItems(orderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error occurred while fetching order items!'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No order items found!'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];

              return Card(
                elevation: 5,
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${item.quantity}'),
                      Text('Price: ${item.price} RM'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
