import 'package:flutter/material.dart';
import 'package:sms/model/post.dart';
import 'package:sms/model/user.dart' as model;
import '../firestore/like_firestore.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final model.User user;

  const PostDetailPage({super.key, required this.post, required this.user});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    bool isLiked = await LikeFirestore.isPostLikedByUser(widget.post.id, widget.user.id);
    setState(() {
      _isLiked = isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the post's image if available
          if (widget.post.imageUrl.isNotEmpty)
            Image.network(
              widget.post.imageUrl,
              fit: BoxFit.cover,
              height: 300, // Adjust height as needed
              width: double.infinity,
            ),
          // Display the user's profile icon and post description
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                widget.user.imagePath != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.imagePath!),
                  radius: 20,
                )
                    : CircleAvatar(
                  child: Icon(Icons.person, size: 20),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.post.description,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.redAccent : Colors.grey,
            ),
            onPressed: () async {
              if (_isLiked) {
                await LikeFirestore.unlikePost(widget.post.id, widget.user.id);
              } else {
                await LikeFirestore.likePost(widget.post.id, widget.user.id);
              }
              setState(() {
                _isLiked = !_isLiked;
              });
            },
          ),
        ],
      ),
    );
  }
}
