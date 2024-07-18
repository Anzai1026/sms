import 'package:flutter/material.dart';
import 'package:sms/firestore/post_firestore.dart';
import 'package:sms/utils/shared_prefs.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  String _imageUrl = ''; // Use any method to get the image URL

  Future<void> _post() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null && _imageUrl.isNotEmpty) {
      await PostFirestore.addPost(uid, _imageUrl, _descriptionController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            // Add any widget to select or take image, and set _imageUrl
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _post,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
