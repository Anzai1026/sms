import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/utils/shared_prefs.dart';

import '../model/user.dart';

class SettingProfilePage extends StatefulWidget {
  const SettingProfilePage({Key? key}) : super(key: key);

  @override
  State<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends State<SettingProfilePage> {
  File? image;
  String? imagePath; // Changed to nullable to better handle state updates
  final ImagePicker _picker = ImagePicker();
  final TextEditingController controller = TextEditingController();

  Future<void> selectImage() async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    setState(() {
      image = File(pickedImage.path);
    });
  }

  Future<void> uploadImage() async {
    if (image == null) {
      // Handle case where user does not select an image
      print('No image selected');
      return;
    }

    try {
      String path = image!.path.substring(image!.path.lastIndexOf('/') + 1);
      final ref = FirebaseStorage.instance.ref(path);
      final storedImage = await ref.putFile(image!);
      imagePath = await storedImage.ref.getDownloadURL();
      setState(() {
        // Update the state variable imagePath with the download URL
        imagePath = imagePath;
      });
      print('Image uploaded: $imagePath');
    } catch (e) {
      print('Failed to upload image: $e');
      // Handle error - show snackbar, toast, or dialog to inform user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 150, child: Text('名前')),
                Expanded(child: TextField(
                  controller: controller,
                ))
              ],
            ),
            const SizedBox(height: 50,),
            Row(
              children: [
                const SizedBox(width: 150, child: Text('プロフィール画像')),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        await selectImage();
                        await uploadImage();
                      },
                      child: const Text('画像を選択'),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30,),
            image == null
                ? const SizedBox()
                : SizedBox(
                width: 200,
                height: 200,
                child: Image.file(image!, fit: BoxFit.cover)
            ),
            const SizedBox(height: 150,),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty || imagePath != null) {
                    User newProfile = User(
                      name: controller.text,
                      imagePath: imagePath,
                      id: SharedPrefs.getUid() ?? '',
                    );
                    await UserFirestore.updateUser(newProfile);
                    // Optionally show success message to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('プロフィールが更新されました')),
                    );
                  } else {
                    // Handle case where no changes were made
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('変更がありません')),
                    );
                  }
                },
                child: const Text('編集'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
