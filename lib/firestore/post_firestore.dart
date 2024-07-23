import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/post.dart';

class PostFirestore {
  static final CollectionReference _postCollection = FirebaseFirestore.instance
      .collection('posts');

  static Future<void> deletePost(String postId) async {
    try {
      await _postCollection.doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
      throw e; // エラーを呼び出し元に投げる
    }
  }

  static Future<void> addPost(String userId, String title, String imageUrl,
      String description) async {
    try {
      await _postCollection.add({
        'userId': userId,
        'title': title,
        'imageUrl': imageUrl,
        'description': description,
      });
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  static Future<List<Post>> getPostsByUserId(String userId) async {
    List<Post> posts = [];
    try {
      QuerySnapshot querySnapshot = await _postCollection.where(
          'userId', isEqualTo: userId).get();
      print('Number of posts fetched: ${querySnapshot.docs
          .length}');
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        posts.add(Post(
          id: doc.id,
          userId: data['userId'],
          imageUrl: data['imageUrl'],
          description: data['description'],
          title: data['title'],
        ));
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
    return posts;
  }
}