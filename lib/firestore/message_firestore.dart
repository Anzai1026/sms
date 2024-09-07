import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/post.dart';

class MessageFirestore {
  static final CollectionReference _messageCollection = FirebaseFirestore.instance.collection('messages');

  // Add a message to Firestore
  static Future<void> addMessage(String userId, String message) async {
    try {
      print('Attempting to add message: $message');
      await _messageCollection.add({
        'userId': userId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Message added successfully!');
    } catch (e) {
      print('Error adding message: $e');
    }
  }

  // Fetch messages for a specific user
  static Future<List<Post>> getMessagesByUserId(String userId) async {
    List<Post> messages = [];
    try {
      print('Fetching messages for user: $userId');
      QuerySnapshot querySnapshot = await _messageCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      print('Number of messages fetched: ${querySnapshot.docs.length}');
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Fetched message data: $data');
        messages.add(Post(
          id: doc.id,
          userId: data['userId'],
          imageUrl: '', // Messages typically do not have images
          description: data['message'],
          title: '', // Assuming messages do not have titles
        ));
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
    return messages;
  }

  // Fetch all messages (for admin or general overview)
  static Future<List<Post>> getAllMessages() async {
    List<Post> messages = [];
    try {
      print('Fetching all messages');
      QuerySnapshot querySnapshot = await _messageCollection
          .orderBy('timestamp', descending: true)
          .get();
      print('Number of messages fetched: ${querySnapshot.docs.length}');
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Fetched message data: $data');
        messages.add(Post(
          id: doc.id,
          userId: data['userId'],
          imageUrl: '', // Messages typically do not have images
          description: data['message'],
          title: '', // Assuming messages do not have titles
        ));
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
    return messages;
  }

  // Delete a specific message by ID
  static Future<void> deleteMessage(String messageId) async {
    try {
      print('Attempting to delete message with ID: $messageId');
      DocumentReference messageDoc = _messageCollection.doc(messageId);
      DocumentSnapshot messageSnapshot = await messageDoc.get();

      if (messageSnapshot.exists) {
        Map<String, dynamic> data = messageSnapshot.data() as Map<String, dynamic>;
        String messageUserId = data['userId'];

        // Check if the user deleting the message is authenticated and is the owner
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && messageUserId == currentUser.uid) {
          await messageDoc.delete();
          print('Message deleted successfully!');
        } else {
          print('User is not authorized to delete this message.');
        }
      } else {
        print('No message found with ID: $messageId');
      }
    } catch (e) {
      print('Error deleting message: $e');
    }
  }
}
