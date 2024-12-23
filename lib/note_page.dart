import 'package:flutter/material.dart';
import 'note.dart';
import 'api.dart';

class ProductDetailPage extends StatelessWidget {
  final Sweet sweet;
  final VoidCallback onDelete;
  final ApiService apiService = ApiService();

  ProductDetailPage({super.key, required this.sweet, required this.onDelete});

  final textFont = const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  Future<void> _deleteProduct(BuildContext context) async {
    final bool confirm = await _showDeleteConfirmationDialog(context);
    if (confirm) {
      try {
        await apiService.deleteProduct(sweet.id);
        onDelete();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении продукта: $e')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удаление товара'),
          content: const Text('Вы уверены, что хотите удалить этот товар?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sweet.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Изображение продукта
            _buildProductImage(context),

            const SizedBox(height: 20),

            // Карточка с описанием
            _buildDescriptionCard(),

            const SizedBox(height: 10),

            // Информация о цене
            _buildDetailRow('Цена:', '${sweet.price.toStringAsFixed(2)} ₽'),

            const SizedBox(height: 20),

            // Кнопка удаления
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          sweet.imageUrl,
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'Не удалось загрузить изображение',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Описание:',
              style: textFont.copyWith(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sweet.description,
              style: textFont,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: textFont.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: textFont.copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _deleteProduct(context),
        icon: const Icon(Icons.delete),
        label: const Text(
          'Удалить товар',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
