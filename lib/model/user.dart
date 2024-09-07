import 'package:sms/model/post.dart';

class User {
  final String id;
  final String? name;
  final String? email;
  final String? imagePath;
  final List<Post>? posts; // Assuming each User has a list of posts

  User({
    required this.id,
    this.name,
    required this.email,
    this.imagePath,
    this.posts,
  });
}