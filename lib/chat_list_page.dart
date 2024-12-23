import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  final String sellerUid;

  const ChatListPage({Key? key, required this.sellerUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список чатов'),
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
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Чатов нет',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          // Извлечение уникальных идентификаторов покупателей
          final buyers = snapshot.data!.docs
              .where((doc) => (doc.data() as Map<String, dynamic>).containsKey('sender'))
              .map((doc) => (doc.data() as Map<String, dynamic>)['sender'] as String)
              .toSet()
              .toList();

          return ListView.builder(
            itemCount: buyers.length,
            itemBuilder: (context, index) {
              final buyerUid = buyers[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(buyerUid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Загрузка...'),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: const Text('Ошибка загрузки пользователя'),
                      subtitle: Text(buyerUid),
                    );
                  }

                  if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
                    return ListTile(
                      title: Text('Пользователь: $buyerUid (не найден)'),
                      trailing: const Icon(Icons.chat),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              sellerUid: sellerUid,
                              buyerUid: buyerUid,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final displayName = userData['name'] ?? 'Пользователь: $buyerUid';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['avatarUrl'] != null
                          ? NetworkImage(userData['avatarUrl'])
                          : null,
                      child: userData['avatarUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(displayName),
                    subtitle: Text('UID: $buyerUid'),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            sellerUid: sellerUid,
                            buyerUid: buyerUid,
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
