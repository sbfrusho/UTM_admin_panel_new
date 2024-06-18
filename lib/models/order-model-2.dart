import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel2 {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final String deliveryTime;
  final double totalPrice;
  final String status;
  final Timestamp createdAt;
  final String uniqueId;

  OrderModel2({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    required this.deliveryTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.uniqueId,
  });

  // Convert the object to a map
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'paymentMethod': paymentMethod,
      'deliveryTime': deliveryTime,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'uniqueId': uniqueId,
    };
  }

  // Create an instance of the class from a map
  factory OrderModel2.fromJson(Map<String, dynamic> json) {
    return OrderModel2(
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      paymentMethod: json['paymentMethod'],
      deliveryTime: json['deliveryTime'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'],
      createdAt: json['createdAt'],
      uniqueId: json['uniqueId'],
    );
  }
}
