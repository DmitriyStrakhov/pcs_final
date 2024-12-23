import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'note.dart';
import 'api.dart';

class BasketPage extends StatefulWidget {
  final Set<Sweet> basketItems;
  final Function(Sweet) onRemoveFromBasket;
  final Function(List<Sweet>) onPurchaseComplete;

  const BasketPage({
    Key? key,
    required this.basketItems,
    required this.onRemoveFromBasket,
    required this.onPurchaseComplete,
  }) : super(key: key);

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final ApiService apiService = ApiService();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  int getTotalPrice() {
    return widget.basketItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _increaseQuantity(Sweet sweet) {
    setState(() {
      sweet.quantity++;
    });
  }

  void _decreaseQuantity(Sweet sweet) {
    setState(() {
      if (sweet.quantity > 1) {
        sweet.quantity--;
      } else {
        widget.onRemoveFromBasket(sweet);
      }
    });
  }

  Future<void> _handlePayment() async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы должны войти в систему, чтобы оформить заказ.')),
      );
      return;
    }

    if (widget.basketItems.isNotEmpty) {
      final purchasedItems = widget.basketItems.toList();
      final totalCost = getTotalPrice();

      try {
        await apiService.createOrder(purchasedItems, totalCost);

        widget.onPurchaseComplete(purchasedItems);
        setState(() {
          widget.basketItems.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ оформлен!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при оформлении заказа: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: widget.basketItems.isEmpty
          ? const Center(child: Text("Ваша корзина пуста"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.basketItems.length,
              itemBuilder: (context, index) {
                final sweet = widget.basketItems.elementAt(index);
                return ListTile(
                  leading: Image.network(
                    sweet.imageUrl,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(sweet.name),
                  subtitle: Text(
                      '${sweet.price} рублей x ${sweet.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _decreaseQuantity(sweet),
                      ),
                      Text(sweet.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _increaseQuantity(sweet),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Общая сумма: $totalPrice рублей',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: widget.basketItems.isNotEmpty && _isLoggedIn
                      ? _handlePayment
                      : null,
                  child: const Text('Оплатить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}