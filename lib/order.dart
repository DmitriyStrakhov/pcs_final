import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id; // Если id документа, то тип String
  final List<OrderItem> products;
  final int totalPrice;
  final DateTime date;

  Order({
    required this.id,
    required this.products,
    required this.totalPrice,
    required this.date,
  });

  factory Order.fromJson(String id, Map<String, dynamic> json) {
    return Order(
      id: id, // Уникальный идентификатор документа Firestore
      products: (json['products'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalPrice: json['total_price'] is String
          ? int.parse(json['total_price'])
          : json['total_price'],
      date: (json['date'] is Timestamp)
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
    );
  }
}

class OrderItem {
  final int productId;
  final String name;
  final int price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] is String
          ? int.parse(json['product_id'])
          : json['product_id'],
      name: json['name'],
      price: json['price'] is String ? int.parse(json['price']) : json['price'],
      quantity: json['quantity'] is String
          ? int.parse(json['quantity'])
          : json['quantity'],
      imageUrl: json['image_url'],
    );
  }
}
