import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/post.dart';

class PostFirestore {
  static final CollectionReference _postCollection = FirebaseFirestore.instance.collection('posts');

  static Future<void> addPost(String userId, String title, String imageUrl, String description) async {
    try {
      print('Attempting to add post: $title');
      await _postCollection.add({
        'userId': userId,
        'title': title,
        'imageUrl': imageUrl,
        'description': description,
      });
      print('Post added successfully!');
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  static Future<List<Post>> getPostsByUserId(String userId) async {
    List<Post> posts = [];
    try {
      print('Fetching posts for user: $userId');
      QuerySnapshot querySnapshot = await _postCollection.where('userId', isEqualTo: userId).get();
      print('Number of posts fetched: ${querySnapshot.docs.length}');
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Fetched post data: $data');
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

  static Future<List<Post>> getAllPosts() async {
    List<Post> posts = [];
    try {
      QuerySnapshot snapshot = await _postCollection.get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        posts.add(Post(
          id: doc.id,
          userId: data['userId'],
          imageUrl: data['imageUrl'],
          description: data['description'],
          title: data['title'],
        ));
      }
      return posts;
    } catch (e) {
      print('Failed to get posts: $e');
      return [];
    }
  }

  static List<Post> shufflePosts(List<Post> posts) {
    final random = Random();
    for (int i = posts.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      var temp = posts[i];
      posts[i] = posts[j];
      posts[j] = temp;
    }
    return posts;
  }

  static Future<void> deletePost(String postId) async {
    try {
      print('Attempting to delete post with ID: $postId');
      DocumentReference postDoc = _postCollection.doc(postId);
      DocumentSnapshot postSnapshot = await postDoc.get();

      if (postSnapshot.exists) {
        await postDoc.delete();
        print('Post deleted successfully!');
      } else {
        print('No post found with ID: $postId');
      }
    } catch (e) {
      print('Error deleting post: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }
}
