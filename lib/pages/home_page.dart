import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms/firestore/message_firestore.dart';
import 'package:sms/firestore/post_firestore.dart';
import 'package:sms/model/post.dart';
import 'package:sms/model/user.dart' as model;
import 'package:sms/pages/post_detail_page.dart';
import 'package:sms/pages/post_page.dart';
import 'package:sms/pages/message_page.dart';
import 'package:sms/utils/shared_prefs.dart';
import '../firestore/like_firestore.dart';
import '../firestore/user_firestore.dart';
import 'main_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;
  List<Post> _posts = [];
  List<Post> _messages = [];
  List<Post> _combinedPostsAndMessages = [];
  Map<String, model.User?> _userProfiles = {};
  Map<String, bool> _likeStatuses = {};
  TextEditingController _textController = TextEditingController();
  bool _isLoadingPosts = true;
  bool _isLoadingMessages = true;

  @override
  void initState() {
    super.initState();
    printUid();
    _fetchData();
  }

  void printUid() async {
    final uid = user.uid;
    await SharedPrefs.setUid(uid);
    if (mounted) {
      print("uid is here : $uid");
    }
  }

  Future<void> _fetchData() async {
    try {
      final postsFuture = _fetchPosts();
      final messagesFuture = _fetchMessages();
      await Future.wait([postsFuture, messagesFuture]);
    } catch (e) {
      print('Data fetch error: $e');
    }
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      List<Post> posts = await PostFirestore.getAllPosts();
      posts = PostFirestore.shufflePosts(posts);

      Map<String, model.User?> userProfiles = {};
      Map<String, bool> likeStatuses = {};

      for (var post in posts) {
        if (!userProfiles.containsKey(post.userId)) {
          model.User? userProfile = await UserFirestore.fetchProfile(post.userId);
          userProfiles[post.userId] = userProfile;
        }

        bool isLiked = await LikeFirestore.isPostLikedByUser(post.id, user.uid);
        likeStatuses[post.id] = isLiked;
      }

      setState(() {
        _posts = posts;
        _userProfiles = userProfiles;
        _likeStatuses = likeStatuses;
        _updateCombinedList();
        _isLoadingPosts = false;
      });
    } catch (e) {
      print('Posts fetch error: $e');
    }
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoadingMessages = true);
    try {
      List<Post> messages = await MessageFirestore.getAllMessages();

      Map<String, model.User?> userProfiles = {};
      for (var message in messages) {
        if (!userProfiles.containsKey(message.userId)) {
          model.User? userProfile = await UserFirestore.fetchProfile(message.userId);
          userProfiles[message.userId] = userProfile;
        }
      }

      setState(() {
        _messages = messages;
        _userProfiles.addAll(userProfiles);
        _updateCombinedList();
        _isLoadingMessages = false;
      });
    } catch (e) {
      print('Messages fetch error: $e');
    }
  }

  void _updateCombinedList() {
    _combinedPostsAndMessages = [..._posts, ..._messages];
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: _selectedIndex,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text(
                'ALIEN.',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.comment_rounded),
              onPressed: () {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagePage()),
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildUserInputSection(),
            Expanded(child: _buildPostList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostPage()),
            );
          },
          tooltip: 'Add Post',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildUserInputSection() {
    model.User? userProfile = _userProfiles[user.uid];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          userProfile?.imagePath != null
              ? CircleAvatar(
            backgroundImage: NetworkImage(userProfile!.imagePath!),
            radius: 20,
          )
              : CircleAvatar(
            child: Icon(Icons.person, size: 20),
            radius: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Write a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String message = _textController.text;
              if (message.isNotEmpty) {
                _postMessage(message);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _postMessage(String message) async {
    try {
      await MessageFirestore.addMessage(user.uid, message);
      _textController.clear();
      await _fetchMessages();
    } catch (e) {
      print('Message posting error: $e');
    }
  }

  Widget _buildPostList() {
    if (_isLoadingPosts || _isLoadingMessages) {
      return Center(child: CircularProgressIndicator());
    }

    return _combinedPostsAndMessages.isEmpty
        ? Center(child: Text('No posts or messages yet.'))
        : ListView.builder(
      itemCount: _combinedPostsAndMessages.length,
      itemBuilder: (context, index) {
        return _buildPostItem(_combinedPostsAndMessages[index]);
      },
    );
  }

  Widget _buildPostItem(Post post) {
    model.User? user = _userProfiles[post.userId];
    bool isLiked = _likeStatuses[post.id] ?? false;

    bool hasImage = post.imageUrl.isNotEmpty;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(
                      post: post,
                      user: user!,
                    ),
                  ),
                );
              },
              child: Image.network(post.imageUrl, fit: BoxFit.cover),
            ),
          Row(
            children: [
              user?.imagePath != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(user!.imagePath!),
                radius: 20,
              )
                  : CircleAvatar(
                child: Icon(Icons.person, size: 20),
                radius: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.redAccent : Colors.grey,
                ),
                onPressed: () async {
                  bool isLiked = _likeStatuses[post.id] ?? false;
                  if (isLiked) {
                    await LikeFirestore.unlikePost(post.id, user!.id);
                  } else {
                    await LikeFirestore.likePost(post.id, user!.id);
                  }
                  setState(() {
                    _likeStatuses[post.id] = !isLiked;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
