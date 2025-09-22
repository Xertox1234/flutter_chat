import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  Future<void> sendMessage(String userId, String message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add({
        'text': message,
        'createdAt': Timestamp.now(),
        'isUserMessage': true,
      });
    } catch (e) {
      print(e);
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
