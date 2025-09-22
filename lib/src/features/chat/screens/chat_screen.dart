import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/login_screen.dart';
import 'package:seniors_companion_app/src/features/authentication/services/auth_service.dart';
import 'package:seniors_companion_app/src/features/chat/models/message.dart';
import 'package:seniors_companion_app/src/features/chat/services/chat_service.dart';
import 'package:seniors_companion_app/src/features/chat/widgets/message_bubble.dart';
import 'package:seniors_companion_app/src/features/chat/widgets/message_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final ChatService chatService = ChatService();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getMessages(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromFirestore(doc))
                    .toList();
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          MessageInputField(userId: user.uid),
        ],
      ),
    );
  }
}
