import 'package:flutter/material.dart';
import 'note.dart';
import 'item_note.dart';
import 'api.dart';
import 'note_page.dart';

class HomePage extends StatefulWidget {
  final Set<Sweet> favoriteSweets;
  final Function(Sweet, bool) onFavoriteChanged;
  final Function(Sweet) onAddToBasket;

  const HomePage({
    Key? key,
    required this.favoriteSweets,
    required this.onFavoriteChanged,
    required this.onAddToBasket,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Sweet> sweets = [];
  List<Sweet> filteredSweets = [];

  final TextEditingController searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String filterType = 'Все';
  bool isDescending = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final products = await apiService.getProducts();
      setState(() {
        sweets = products;
        filteredSweets = List.from(sweets);
      });
    } catch (e) {
      print("Ошибка при загрузке продуктов: $e");
    }
  }

  Future<void> _addNewSweet() async {
    final newSweet = Sweet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      isFavorite: false,
    );

    try {
      await apiService.createProduct(newSweet);
      setState(() {
        sweets.add(newSweet);
        filteredSweets = List.from(sweets);
      });
    } catch (e) {
      print("Ошибка при добавлении продукта: $e");
    }

    _nameController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _priceController.clear();
  }

  void _showAddSweetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новый товар'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL изображения'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Цена'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addNewSweet();
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFavorite(Sweet sweet) {
    final isFavorite = widget.favoriteSweets.contains(sweet);
    widget.onFavoriteChanged(sweet, !isFavorite);
  }

  void _updateFilteredProducts() {
    List<Sweet> tempSweets = List.from(sweets);

    if (filterType == 'Цена') {
      tempSweets.sort((a, b) =>
      isDescending ? b.price.compareTo(a.price) : a.price.compareTo(b.price));
    } else if (filterType == 'Название') {
      tempSweets.sort((a, b) =>
      isDescending
          ? b.name.toLowerCase().compareTo(a.name.toLowerCase())
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      tempSweets = tempSweets
          .where((sweet) => sweet.name.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      filteredSweets = tempSweets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Фильтр товаров'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: filterType,
                          isExpanded: true,
                          items: ['Все', 'Цена', 'Название'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              filterType = newValue!;
                              if (filterType != 'Цена') {
                                isDescending = false;
                              }
                              _updateFilteredProducts();
                            });
                          },
                        ),
                        if (filterType == 'Цена')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('По убыванию'),
                              Switch(
                                value: isDescending,
                                onChanged: (value) {
                                  setState(() {
                                    isDescending = value;
                                    _updateFilteredProducts();
                                  });
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Закрыть'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => _updateFilteredProducts(),
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredSweets.isEmpty
                ? const Center(
              child: Text(
                'Нет доступных товаров',
                style: TextStyle(fontSize: 18),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: filteredSweets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 2 / 3,
              ),
              itemBuilder: (context, index) {
                final sweet = filteredSweets[index];
                final isFavorite = widget.favoriteSweets.contains(sweet);

                return Item(
                  sweet: sweet,
                  isFavorite: isFavorite,
                  onAddToBasket: () {
                    widget.onAddToBasket(sweet);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${sweet.name} добавлен в корзину')),
                    );
                  },
                  onToggleFavorite: () {
                    _toggleFavorite(sweet);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${sweet.name} ${isFavorite ? "удален из избранного" : "добавлен в избранное"}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSweetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
