import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart'; // Страница чата

class SellerChatsPage extends StatelessWidget {
  final String sellerUid;

  const SellerChatsPage({super.key, required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты покупателей'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('receiverId', isEqualTo: sellerUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Нет сообщений'));
          }

          // Получаем уникальных покупателей, которые отправляли сообщения
          final buyers = snapshot.data!.docs
              .map((doc) => doc['senderId'] as String)
              .toSet()
              .toList();

          return ListView.builder(
            itemCount: buyers.length,
            itemBuilder: (context, index) {
              final buyerId = buyers[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(buyerId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Загрузка...'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Пользователь: $buyerId'),
                      trailing: const Icon(Icons.chat),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              sellerUid: sellerUid,
                              buyerUid: buyerId,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final buyerName = userData['name'] ?? 'Пользователь: $buyerId';

                  return ListTile(
                    title: Text(buyerName),
                    leading: CircleAvatar(
                      child: Text(buyerName[0]), // Инициалы пользователя
                    ),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            sellerUid: sellerUid,
                            buyerUid: buyerId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
