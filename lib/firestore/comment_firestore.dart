// lib/firestore/comment_firestore.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentFirestore {
  static final CollectionReference _commentCollection = FirebaseFirestore.instance.collection('comments');

  // Add a comment to Firestore
  static Future<void> addComment(String userId, String postId, String commentText) async {
    try {
      print('Attempting to add comment: $commentText');
      await _commentCollection.add({
        'userId': userId,
        'postId': postId,
        'text': commentText,
        'timestamp': FieldValue.serverTimestamp(),
        // Optionally add user profile details if needed
      });
      print('Comment added successfully!');
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // Fetch comments for a specific post
  static Future<List<Comment>> getCommentsByPostId(String postId) async {
    List<Comment> comments = [];
    try {
      print('Fetching comments for post: $postId');
      QuerySnapshot querySnapshot = await _commentCollection
          .where('postId', isEqualTo: postId)
          .orderBy('timestamp', descending: true)
          .get();
      print('Number of comments fetched: ${querySnapshot.docs.length}');
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Fetched comment data: $data');
        comments.add(Comment(
          userId: data['userId'],
          text: data['text'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          // Optionally add user profile details if needed
        ));
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
    return comments;
  }
}

class Comment {
  final String userId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.text,
    required this.timestamp,
  });
}
