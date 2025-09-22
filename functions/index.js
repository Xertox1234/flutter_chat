const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.echo = functions.firestore
  .document("chats/{userId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const userId = context.params.userId;

    if (message.isUserMessage) {
      await admin
        .firestore()
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .add({
          text: `You said: ${message.text}`,
          createdAt: new Date(),
          isUserMessage: false,
        });
    }
  });
