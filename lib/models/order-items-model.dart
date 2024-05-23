import 'package:admin_panel/models/order-model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveOrder(OrderModel order, List<OrderItemModel> items) async {
    try {
      DocumentReference orderRef = await _firestore.collection('orders').add(order.toJson());
      for (OrderItemModel item in items) {
        await orderRef.collection('items').add(item.toJson());
      }
    } catch (e) {
      print('Error saving order: $e');
    }
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}
