import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart' as customOrder;
import 'note.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение списка продуктов
  Future<List<Sweet>> getProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      List<Sweet> products = querySnapshot.docs
          .map((doc) => Sweet.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return products;
    } catch (e) {
      throw Exception('Не удалось загрузить продукты: $e');
    }
  }

  // Создание продукта
  Future<void> createProduct(Sweet sweet) async {
    try {
      await _firestore.collection('products').doc(sweet.id).set(sweet.toJson());
    } catch (e) {
      throw Exception('Не удалось создать продукт: $e');
    }
  }

  // Получение продукта по ID
  Future<Sweet> getProductByID(int id) async {
    try {
      final docSnapshot = await _firestore.collection('products').doc(id.toString()).get();
      if (!docSnapshot.exists) {
        throw Exception('Продукт не найден');
      }
      return Sweet.fromJson(docSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Продукт не найден: $e');
    }
  }

  // Удаление продукта
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Не удалось удалить продукт: $e');
    }
  }

  // Получение истории заказов
  Future<List<customOrder.Order>> getOrderHistory() async {
    try {
      final querySnapshot = await _firestore.collection('orders').get();
      List<customOrder.Order> orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return customOrder.Order.fromJson(doc.id, data);
      }).toList();
      return orders;
    } catch (e) {
      throw Exception('Не удалось загрузить историю заказов: $e');
    }
  }

  // Создание заказа
  Future<void> createOrder(List<Sweet> orderItems, int totalCost) async {
    try {
      final data = {
        "products": orderItems
            .map((sweet) => {
          "product_id": sweet.id,
          "name": sweet.name,
          "price": sweet.price,
          "quantity": sweet.quantity,
          "image_url": sweet.imageUrl,
        })
            .toList(),
        "total_price": totalCost,
        "date": DateTime.now().toIso8601String(),
      };

      await _firestore.collection('orders').add(data);
    } catch (e) {
      throw Exception('Не удалось отправить заказ: $e');
    }
  }
}
