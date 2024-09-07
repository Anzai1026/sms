import 'package:cloud_firestore/cloud_firestore.dart';

class LikeFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;
  static final _likesCollection = _firebaseFirestoreInstance.collection('likes');

  // Check if a post is liked by a specific user
  static Future<bool> isPostLikedByUser(String postId, String userId) async {
    try {
      final docSnapshot = await _likesCollection.doc('$postId-$userId').get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  // Add a like to a post by a user
  static Future<void> likePost(String postId, String userId) async {
    try {
      await _likesCollection.doc('$postId-$userId').set({
        'post_id': postId,
        'user_id': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  // Remove a like from a post by a user
  static Future<void> unlikePost(String postId, String userId) async {
    try {
      await _likesCollection.doc('$postId-$userId').delete();
    } catch (e) {
      print('Error unliking post: $e');
    }
  }

  // Get the like count for a specific post
  static Future<int> getLikeCount(String postId) async {
    try {
      final querySnapshot = await _likesCollection.where('post_id', isEqualTo: postId).get();
      return querySnapshot.size;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }
}
