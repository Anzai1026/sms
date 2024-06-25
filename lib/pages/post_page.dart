import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  void _uploadPost() {
    // Implement your post upload logic here (e.g., save to Firestore, etc.)
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Simulate a delay to mimic server interaction
    Future.delayed(Duration(seconds: 2), () {
      // After upload, you can navigate back to the previous screen or show a success message
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      Navigator.pop(context); // Navigate back after posting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _uploadPost,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: Text('Add Image Preview'), // Replace with actual image upload widget
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: 20.0),
            // Add more fields for tagging users, location, etc. as needed
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
