import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String userId;
  final String imageUrl;
  final String description;
  final String title;

  Post({
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.title,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'title' : title,
    };
  }
}
