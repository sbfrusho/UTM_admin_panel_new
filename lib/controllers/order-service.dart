import 'package:admin_panel/models/order-model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order-items-model.dart';

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

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .doc(orderId)
          .collection('items')
          .get();
      return querySnapshot.docs.map((doc) {
        return OrderItemModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }
}
