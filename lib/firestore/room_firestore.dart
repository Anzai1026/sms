import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/talk_room.dart';
import 'package:sms/model/user.dart';
import 'package:sms/utils/shared_prefs.dart';

class RoomFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference _roomCollection = _firebaseFirestoreInstance.collection('room');
  static final joinedRoomSnapshot = _roomCollection.where('joined_user_ids', arrayContains: SharedPrefs.fetchUid()).snapshots();

  // メッセージ削除のメソッド
  static Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      await _roomCollection.doc(roomId).collection('message').doc(messageId).delete();
    } catch (e) {
      print('メッセージの削除失敗 ===== $e');
    }
  }

  static Future<void> createRoom(String myUid) async {
    try {
      final docs = await UserFirestore.fetchUsers();
      if (docs == null) return;
      for (var doc in docs) {
        if (doc.id == myUid) continue;
        await _roomCollection.add({
          'joined_user_ids': [doc.id, myUid],
          'created_time': Timestamp.now()
        });
      }
    } catch (e) {
      print('ルーム作成失敗 ===== $e');
    }
  }

  static Future<List<TalkRoom>?> fetchJoinedRooms(QuerySnapshot snapshot) async {
    try {
      String myUid = SharedPrefs.fetchUid()!;
      List<TalkRoom> talkRooms = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> userIds = data['joined_user_ids'];
        late String talkUserUid;
        for (var id in userIds) {
          if (id == myUid) continue;
          talkUserUid = id;
        }
        User? talkUser = await UserFirestore.fetchProfile(talkUserUid);
        if (talkUser == null) return null;
        final talkRoom = TalkRoom(
            roomId: doc.id,
            talkUser: talkUser,
            lastMessage: data['last_message']
        );
        talkRooms.add(talkRoom);
      }
      return talkRooms;
    } catch (e) {
      print('参加してるルームの取得失敗 ----- $e');
      return null;
    }
  }

  static Stream<QuerySnapshot> fetchMessageSnapshot(String roomId) {
    return _roomCollection.doc(roomId).collection('message').orderBy('send_time', descending: true).snapshots();
  }

  static Future<void> sendMessage({required String roomId, required String message, String replyToMessage = ''}) async {
    try {
      final messageCollection = _roomCollection.doc(roomId).collection('message');
      await messageCollection.add({
        'message': message,
        'sender_id': SharedPrefs.fetchUid(),
        'send_time': Timestamp.now(),
        'reply_to_message': replyToMessage,
      });

      await _roomCollection.doc(roomId).update({
        'last_message': message
      });

    } catch (e) {
      print('メッセージの送信失敗 ===== $e');
    }
  }
}