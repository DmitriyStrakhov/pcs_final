import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat_list_page.dart';

class ChatPage extends StatefulWidget {
  final String sellerUid;
  final String buyerUid;

  const ChatPage({Key? key, required this.sellerUid, required this.buyerUid}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Получение UID текущего пользователя
  String? get currentUserUid => FirebaseAuth.instance.currentUser?.uid;

  /// Метод для отправки сообщения
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && currentUserUid != null) {
      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'sender': currentUserUid, // Отправитель - текущий пользователь
          'receiverId': widget.buyerUid, // Получатель - покупатель
          'text': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        _messageController.clear(); // Очистка поля после отправки
        _scrollToBottom(); // Прокрутка вниз после отправки
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось отправить сообщение: $e')),
        );
      }
    }
  }

  /// Прокрутка чата вниз
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Сообщений нет'));
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final sender = data['sender'];
                  final receiver = data['receiverId'];

                  return (sender == currentUserUid && receiver == widget.buyerUid) ||
                      (sender == widget.buyerUid && receiver == currentUserUid);
                }).toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = message['sender'] == currentUserUid;

                    return ListTile(
                      title: Align(
                        alignment:
                        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.redAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isCurrentUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment:
                        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          message['timestamp'] != null
                              ? (message['timestamp'] as Timestamp)
                              .toDate()
                              .toLocal()
                              .toString()
                              : '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Введите сообщение...',
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
