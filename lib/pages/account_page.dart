import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/user.dart';
import 'package:sms/pages/drawer.dart';
import 'package:sms/pages/search_page.dart';
import 'package:sms/utils/shared_prefs.dart';
import 'package:sms/firestore/post_firestore.dart';
import 'home_page.dart';

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? _user;
  bool _isFollowing = false;
  int _selectedIndex = 3;
  List<Map<String, dynamic>> _posts = [];

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void navigateToPage(Widget page) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkFollowing();
    _fetchUserPosts();
  }

  Future<void> _fetchUserProfile() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null) {
      User? user = await UserFirestore.fetchProfile(uid);
      if (user != null && mounted) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  Future<void> _checkFollowing() async {
    String? loginUid = await SharedPrefs.getUid();
    if (loginUid != null && _user != null) {
      bool isFollowing = await UserFirestore.isFollowing(loginUid, _user!.id);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null) {
      List<Map<String, dynamic>> posts = await PostFirestore.fetchUserPosts(uid);
      if (mounted) {
        setState(() {
          _posts = posts;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    String? loginUid = await SharedPrefs.getUid();
    if (loginUid != null && _user != null) {
      if (_isFollowing) {
        await UserFirestore.unfollow(loginUid, _user!.id);
      } else {
        await UserFirestore.follow(loginUid, _user!.id);
      }
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                onPressed: () {
                  if (mounted) {
                    navigateToPage(HomePage());
                  }
                },
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
                onPressed: () {
                  if (mounted) {
                    navigateToPage(SearchPage());
                  }
                },
              ),
              GButton(
                icon: Icons.slow_motion_video,
                text: 'Reels',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              if (mounted) {
                _onItemTapped(index);
              }
            },
          ),
        ),
      ),
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
      ),
      endDrawer: MyWidget(),
      body: _user != null ? _buildProfile() : _buildLoading(),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircleAvatar(
              backgroundImage: _user?.imagePath != null
                  ? NetworkImage(_user!.imagePath!)
                  : const NetworkImage("https://example.com/default.jpg"),
              radius: 50,
            ),
          ),
          Text(
              _user?.name ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
              _user?.id ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Text('100', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Posts'),
                  ],
                ),
                Row(
                  children: [
                    Text('200', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Followers'),
                  ],
                ),
                Row(
                  children: [
                    Text('150', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Following'),
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
                  child: const Text('Follow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white60,
                    minimumSize: const Size(160, 40),
                  ),
                  child: const Text('Message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 20),
          _buildPostGrid(),
        ],
      ),
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
          child: Image.network(
            _posts[index]['imageUrl'],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
