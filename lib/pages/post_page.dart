import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms/firestore/post_firestore.dart';
import 'package:sms/utils/shared_prefs.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _takePicture() async {
    XFile? picture = await _picker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      setState(() {
        _image = File(picture.path);
      });
    }
  }

  Future<void> _post() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null && _image != null) {
      // Upload image to Firebase Storage
      String imageUrl = await _uploadImageToStorage(_image!);

      // Add post to Firestore with correct argument order
      await PostFirestore.addPost(uid, _titleController.text, imageUrl, _descriptionController.text);

      // Navigate back
      Navigator.pop(context);
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(DateTime.now().toString() + '.jpg');

    await ref.putFile(imageFile);

    String imageUrl = await ref.getDownloadURL();

    return imageUrl;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Show dialog to select source: camera or gallery
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Image Source'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            GestureDetector(
                              child: Text('Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _selectImage();
                              },
                            ),
                            Padding(padding: EdgeInsets.all(10.0)),
                            GestureDetector(
                              child: Text('Camera'),
                              onTap: () {
                                Navigator.pop(context);
                                _takePicture();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _image != null
                    ? Image.file(
                  _image!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.add_a_photo,
                  color: Colors.grey[800],
                  size: 50.0,
                ),
                alignment: Alignment.center,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
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
