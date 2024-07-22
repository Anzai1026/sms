import 'package:flutter/material.dart';
import 'package:sms/model/user.dart';
import 'package:sms/model/talk_room.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/pages/talk_room_page.dart';
import 'package:sms/utils/shared_prefs.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/post.dart';
import 'package:sms/firestore/post_firestore.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isFollowing = false;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _checkFollowing();
    _fetchUserPosts();
  }

  Future<void> _checkFollowing() async {
    String? loginUid = await SharedPrefs.getUid();
    if (loginUid != null) {
      bool isFollowing = await UserFirestore.isFollowing(loginUid, widget.user.id);
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  Future<void> _fetchUserPosts() async {
    List<Post> posts = await PostFirestore.getPostsByUserId(widget.user.id);
    setState(() {
      _posts = posts;
    });
  }

  Future<void> _toggleFollow() async {
    String? loginUid = await SharedPrefs.getUid();
    if (loginUid != null) {
      if (_isFollowing) {
        await UserFirestore.unfollow(loginUid, widget.user.id);
      } else {
        await UserFirestore.follow(loginUid, widget.user.id);
      }
      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }

  Future<void> _createAndNavigateToTalkRoom(BuildContext context) async {
    try {
      String myUid = SharedPrefs.fetchUid()!;
      String otherUserUid = widget.user.id;

      String roomId = await RoomFirestore.createRoom(myUid, otherUserUid);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              widget.user.imagePath != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(widget.user.imagePath!),
                radius: 50,
              )
                  : CircleAvatar(
                child: Icon(Icons.person, size: 50),
                radius: 50,
              ),
              SizedBox(height: 10),
              Text(widget.user.id, style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
                      minimumSize: const Size(160, 40),
                    ),
                    child: Text(
                      _isFollowing ? 'Unfollow' : 'Follow',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
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
              const SizedBox(height: 20),
              Expanded(
                child: _buildPostGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return Image.network(
          _posts[index].imageUrl,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
