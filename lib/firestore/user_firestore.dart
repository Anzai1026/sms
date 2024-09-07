import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/user.dart';
import 'package:sms/utils/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;
  static final _userCollection = _firebaseFirestoreInstance.collection('user');
  static final _followCollection = _firebaseFirestoreInstance.collection('follow');

  // フォロー機能
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

  // 新しいアカウントの作成
  static Future<String?> insertNewAccount() async {
    try {
      final firebase_auth.UserCredential userCredential =
      await firebase_auth.FirebaseAuth.instance.signInAnonymously();
      final String uid = userCredential.user!.uid;

      await _userCollection.doc(uid).set({
        'name': 'Anonymous',
        'image_path': '', // デフォルトの値
        'email': '',      // デフォルトの値
        'created_at': FieldValue.serverTimestamp(),
      });

      return uid;
    } catch (e) {
      print('アカウント作成失敗: $e');
      return null;
    }
  }

  // 新規ユーザー作成とトークルーム作成
  static Future<void> createUser() async {
    final myUid = await insertNewAccount();
    if (myUid != null) {
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

  // Firestoreからユーザー一覧を取得
  static Future<List<QueryDocumentSnapshot>?> fetchUsers() async {
    try {
      final snapshot = await _userCollection.get();
      return snapshot.docs;
    } catch (e) {
      print('ユーザー情報の取得失敗 ===== $e');
      return null;
    }
  }

  // ユーザープロフィールの更新
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

  // ユーザープロフィールの取得
  static Future<User?> fetchProfile(String uid) async {
    try {
      final snapshot = await _userCollection.doc(uid).get();
      if (snapshot.exists) {
        return User(
          id: uid,
          name: snapshot.data()!['name'],
          imagePath: snapshot.data()!['image_path'],
          email: snapshot.data()!['email'],
        );
      } else {
        return null;
      }
    } catch (e) {
      print('ユーザー情報の取得失敗 ----- $e');
      return null;
    }
  }

  // ユーザープロフィールの取得 (Userクラスの詳細をMap形式で返す)
  static Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      final snapshot = await _userCollection.doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('ユーザー情報の取得失敗 ----- $e');
      return null;
    }
  }
}
