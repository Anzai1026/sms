import 'package:cloud_firestore/cloud_firestore.dart';

class PostFirestore {
  static final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference _postCollection = _firestoreInstance.collection('posts');

  static Future<List<Map<String, dynamic>>> fetchUserPosts(String userId) async {
    QuerySnapshot snapshot = await _postCollection.where('userId', isEqualTo: userId).get();
    List<Map<String, dynamic>> posts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    return posts;
  }

  static Future<void> addPost(String userId, String imageUrl, String description) async {
    await _postCollection.add({
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }
}
