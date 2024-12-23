import 'auth_service.dart';
import 'package:flutter/material.dart';
import 'chat_list_page.dart';
import 'edit_profile_page.dart';
import 'order_history_page.dart';
import 'chat_page.dart';

class ProfilePage extends StatefulWidget {
  final Function onSignOut;

  const ProfilePage({super.key, required this.onSignOut});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = 'Акулка';
  String _phone = '+7 (777) 777 77-77';
  String _avatarUrl = 'https://fishnews.ru/news/49523';
  String _role = 'Покупатель';

  final authService = AuthService();

  void _editProfile(String fullName, String phone, String avatarUrl) {
    setState(() {
      _fullName = fullName;
      _phone = phone;
      _avatarUrl = avatarUrl;
    });
  }

  void _onMenuSelected(String value) {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            fullName: _fullName,
            phone: _phone,
            avatarUrl: _avatarUrl,
            onSave: _editProfile,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = authService.getCurrentUserEmail();
    final currentUserUid = authService.getCurrentUserUid();

    // Определение роли
    if (currentUserUid == "qSVrgQjZaXfxRTRu5ksjmtMX6oH2") {
      _role = "Продавец";
    } else {
      _role = "Покупатель";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Профиль',
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.edit, color: Colors.greenAccent),
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Редактировать профиль'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(_avatarUrl),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullName,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentEmail.toString(),
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _phone,
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Роль: $_role',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryPage(),
                    ),
                  );
                },
                child: const Text('История заказов'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_role == "Продавец") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatListPage(
                          sellerUid: currentUserUid!,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatListPage(
                          sellerUid: "qSVrgQjZaXfxRTRu5ksjmtMX6oH2",
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  _role == "Продавец" ? 'Чаты с покупателями' : 'Чат с продавцом',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  widget.onSignOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Выйти',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
