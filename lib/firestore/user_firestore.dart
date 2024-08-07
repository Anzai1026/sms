import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/user.dart';
import 'package:sms/utils/shared_prefs.dart';

class UserFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;
  static final _userCollection = _firebaseFirestoreInstance.collection('user');
  static final _followCollection = _firebaseFirestoreInstance.collection('follow');

  static Future<void> follow(String followerUid, String followedUid) async {
    try {
      await _followCollection.doc('$followerUid-$followedUid').set({
        'follower_uid': followerUid,
        'followed_uid': followedUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('フォロー失敗 ===== $e');
    }
  }

  static Future<bool> isFollowing(String followerUid, String followedUid) async {
    try {
      final docSnapshot = await _followCollection.doc('$followerUid-$followedUid').get();
      return docSnapshot.exists;
    } catch (e) {
      print('フォロー状況の取得失敗 ===== $e');
      return false;
    }
  }

  static Future<void> unfollow(String followerUid, String followedUid) async {
    try {
      await _followCollection.doc('$followerUid-$followedUid').delete();
    } catch (e) {
      print('フォロー解除失敗 ===== $e');
    }
  }

  static Future<String?> insertNewAccount() async {
    // アカウント作成の処理を実装
  }

  static Future<void> createUser() async {
    final myUid = await insertNewAccount();
    if (myUid != null) {
      // 他のユーザーのUIDを取得して、トークルームを作成します。
      final users = await fetchUsers();
      if (users != null) {
        for (var userDoc in users) {
          final otherUserUid = userDoc.id;
          if (otherUserUid != myUid) {
            await RoomFirestore.createRoom(myUid, otherUserUid);
          }
        }
      }
      await SharedPrefs.setUid(myUid);
    }
  }

  static Future<List<QueryDocumentSnapshot>?> fetchUsers() async {
    try {
      final snapshot = await _userCollection.get();
      return snapshot.docs;
    } catch (e) {
      print('ユーザー情報の取得失敗 ===== $e');
      return null;
    }
  }

  static Future<void> updateUser(User newProfile) async {
    try {
      await _userCollection.doc(newProfile.id).update({
        'name': newProfile.name,
        'image_path': newProfile.imagePath
      });
    } catch (e) {
      print('ユーザー情報の更新失敗 ----- $e');
    }
  }

  static Future<User?> fetchProfile(String uid) async {
    try {
      final snapshot = await _userCollection.doc(uid).get();
      User user = User(
          name: snapshot.data()!['name'],
          imagePath: snapshot.data()!['image_path'],
          id: uid
      );
      print(snapshot.data()!['name']);
      return user;
    } catch (e) {
      print('自分のユーザーの情報の取得失敗 ----- $e');
      return null;
    }
  }
}
