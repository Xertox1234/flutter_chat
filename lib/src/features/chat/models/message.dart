import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final Timestamp createdAt;
  final bool isUserMessage;

  Message({
    required this.text,
    required this.createdAt,
    required this.isUserMessage,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      text: data['text'],
      createdAt: data['createdAt'],
      isUserMessage: data['isUserMessage'],
    );
  }
}
