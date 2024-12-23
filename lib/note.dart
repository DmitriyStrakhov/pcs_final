class Sweet {
  final String id; // Используем строку вместо числа
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final bool isFavorite;
  int quantity;

  Sweet({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
    this.quantity = 1,
  });

  factory Sweet.fromJson(Map<String, dynamic> json) {
    return Sweet(
      id: json['id']?.toString() ?? '', // Преобразуем null в пустую строку
      name: json['name'] ?? 'Без названия', // Значение по умолчанию
      description: json['description'] ?? 'Описание отсутствует',
      imageUrl: json['image_url'] ?? '', // Если изображения нет, оставить пустым
      price: json['price'] ?? 0, // Цена по умолчанию 0
      isFavorite: json['is_favorite'] ?? false,
      quantity: json['quantity'] ?? 1,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'is_favorite': isFavorite,
      'quantity': quantity,
    };
  }
}
