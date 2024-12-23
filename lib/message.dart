import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sender;
  final String receiverId; // Добавлено поле receiverId
  final String text;
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.receiverId, // Инициализация receiverId
    required this.text,
    required this.timestamp,
  });

  // Конструктор fromJson с дополнительной проверкой
  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      return Message(
        sender: json['sender'] ?? 'Unknown', // Значение по умолчанию, если 'sender' пустое
        receiverId: json['receiverId'] ?? 'Unknown', // Значение по умолчанию для receiverId
        text: json['text'] ?? '',
        timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), // Текущая дата, если timestamp пустой
      );
    } catch (e) {
      // Логирование или вывод ошибки, если что-то пошло не так
      throw Exception('Ошибка при создании сообщения из JSON: $e');
    }
  }

  // Метод toJson
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiverId': receiverId, // Добавлено поле receiverId
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp), // Преобразуем DateTime в Firestore Timestamp
    };
  }
}
