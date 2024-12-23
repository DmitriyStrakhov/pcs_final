import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart'; // Импорт страницы регистрации покупателя
import 'register_seller.dart'; // Импорт страницы регистрации продавца

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Вход")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Пароль"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Войти"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Переход на экран регистрации покупателя
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Нет аккаунта? Зарегистрируйтесь как покупатель"),
            ),
            TextButton(
              onPressed: () {
                // Переход на экран регистрации продавца
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterSellerPage()),
                );
              },
              child: const Text("Нет аккаунта? Зарегистрируйтесь как продавец"),
            ),
          ],
        ),
      ),
    );
  }
}
