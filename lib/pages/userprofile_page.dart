import 'package:flutter/material.dart';
import 'package:sms/model/user.dart';
import 'package:sms/model/talk_room.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/pages/talk_room_page.dart';
import 'package:sms/utils/shared_prefs.dart';

import '../firestore/user_firestore.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  Future<void> _createAndNavigateToTalkRoom(BuildContext context) async {
    try {
      // 自分のユーザーIDを取得
      String myUid = SharedPrefs.fetchUid()!;
      String otherUserUid = user.id;

      // トークルームを作成または既存のものを取得
      String roomId = await RoomFirestore.createRoom(myUid, otherUserUid);

      // トークルームページに遷移する
      User? recipientUser = await UserFirestore.fetchProfile(otherUserUid);
      if (recipientUser != null) {
        TalkRoom newRoom = TalkRoom(
          roomId: roomId,
          talkUser: recipientUser,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TalkRoomPage(talkRoom: newRoom),
          ),
        );
      }
    } catch (e) {
      print('Error creating talk room: $e');
      // エラーハンドリングが必要な場合はここに追加します
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              user.imagePath != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(user.imagePath!),
                radius: 50,
              )
                  : CircleAvatar(
                child: Icon(Icons.person, size: 50),
                radius: 50,
              ),
              SizedBox(height: 10),
              Text(user.id, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text('100', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Posts'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('200', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Followers'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('150', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Following'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white60,
                      minimumSize: const Size(160, 40),
                    ),
                    child: const Text('Follow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _createAndNavigateToTalkRoom(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white60,
                      minimumSize: const Size(160, 40),
                    ),
                    child: const Text('Message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
