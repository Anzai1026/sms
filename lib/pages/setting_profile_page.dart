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
  String? imagePath;
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
      print('No image selected');
      return;
    }

    try {
      String path = image!.path.substring(image!.path.lastIndexOf('/') + 1);
      final ref = FirebaseStorage.instance.ref(path);
      final storedImage = await ref.putFile(image!);
      imagePath = await storedImage.ref.getDownloadURL();
      setState(() {
        imagePath = imagePath;
      });
      print('Image uploaded: $imagePath');
    } catch (e) {
      print('Failed to upload image: $e');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 100, child: Text('名前', style: TextStyle(fontSize: 16))),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '名前を入力',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('プロフィール画像', style: TextStyle(fontSize: 16))),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await selectImage();
                      await uploadImage();
                    },
                    child: const Text('画像を選択'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (image != null)
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.file(image!, fit: BoxFit.cover),
                ),
              ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty || imagePath != null) {
                      User newProfile = User(
                        name: controller.text,
                        imagePath: imagePath,
                        id: SharedPrefs.getUid() ?? '', email: '',
                      );
                      await UserFirestore.updateUser(newProfile);
                      await SharedPrefs.setUser(newProfile);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('プロフィールが更新されました')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('変更がありません')),
                      );
                    }
                  },
                  child: const Text('編集'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
