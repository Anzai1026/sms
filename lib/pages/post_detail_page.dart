import 'package:flutter/material.dart';
import 'package:sms/model/post.dart';

import '../model/user.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  final User user;

  const PostDetailPage({Key? key, required this.post, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(post.imageUrl),
            SizedBox(height: 16),
            Text(post.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(post.description),
            SizedBox(height: 16),
            Text('Posted by: ${user.name}', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
