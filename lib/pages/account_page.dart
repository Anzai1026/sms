import 'package:flutter/material.dart';
import 'package:sms/firestore/message_firestore.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/message.dart';
import 'package:sms/model/post.dart';
import 'package:sms/model/user.dart';
import 'package:sms/pages/drawer.dart';
import 'package:sms/pages/post_detail_page.dart';
import 'package:sms/pages/setting_profile_page.dart';
import 'package:sms/utils/shared_prefs.dart';
import '../firestore/post_firestore.dart';
import 'main_layout.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? _user;
  int _selectedIndex = 2;
  List<Post> _posts = [];
  List<Post> _messages = [];
  bool _isLoading = true;
  bool _showPosts = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserPosts();
    _fetchUserMessages();
  }

  Future<void> _fetchUserProfile() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null) {
      User? user = await UserFirestore.fetchProfile(uid);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null) {
      List<Post> posts = await PostFirestore.getPostsByUserId(uid);
      if (mounted) {
        setState(() {
          _posts = posts;
        });
      }
    }
  }

  Future<void> _fetchUserMessages() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null) {
      List<Post> messages = await MessageFirestore.getMessagesByUserId(uid);
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    }
  }

  void _showDeleteDialog(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePost(post.id); // Call the delete method
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await PostFirestore.deletePost(postId);
      setState(() {
        _posts.removeWhere((post) => post.id == postId);
      });
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainLayout(
      selectedIndex: _selectedIndex, // Ensure the bottom navigation reflects the AccountPage
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text(
                _user?.name ?? '',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        endDrawer: MyWidget(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _user!.imagePath != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(_user!.imagePath!),
                      radius: 50,
                    )
                        : CircleAvatar(
                      child: Icon(Icons.person, size: 50),
                      radius: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _user!.id,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text('100',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text('Posts'),
                            ],
                          ),
                          Row(
                            children: [
                              Text('200',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text('Followers'),
                            ],
                          ),
                          Row(
                            children: [
                              Text('150',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
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
                          onPressed: () {
                            setState(() {
                              _showPosts = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: _showPosts ? Colors.white : Colors.black,
                            backgroundColor: _showPosts ? Colors.black : Colors.white60,
                            minimumSize: const Size(160, 40),
                          ),
                          child: const Text('Posts',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showPosts = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: !_showPosts ? Colors.white : Colors.black,
                            backgroundColor: !_showPosts ? Colors.black : Colors.white60,
                            minimumSize: const Size(160, 40),
                          ),
                          child: const Text('Messages',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _showPosts ? _buildGrid(_posts) : _buildList(_messages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<Post> items) {
    return items.isEmpty
        ? Center(child: Text('No items available'))
        : GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(
                  post: items[index],
                  user: _user!,
                ),
              ),
            );
          },
          onLongPress: () {
            _showDeleteDialog(items[index]);
          },
          child: Image.network(
            items[index].imageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildList(List<Post> items) {
    return items.isEmpty
        ? Center(child: Text('No items available'))
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            _showDeleteDialog(items[index]);
          },
          child: _buildPostItem(items[index]),
        );
      },
    );
  }

  Widget _buildPostItem(Post post) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl.isNotEmpty) // Only show image if available
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(post.imageUrl, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
