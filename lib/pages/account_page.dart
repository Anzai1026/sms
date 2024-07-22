import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/post.dart';
import 'package:sms/model/user.dart';
import 'package:sms/pages/drawer.dart';
import 'package:sms/pages/post_detail_page.dart';  // PostDetailPageをインポート
import 'package:sms/pages/search_page.dart';
import 'package:sms/pages/setting_profile_page.dart';
import 'package:sms/utils/shared_prefs.dart';
import '../firestore/post_firestore.dart';
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
  List<Post> _posts = [];
  int _selectedIndex = 3;
  bool _isLoading = true;

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
    _fetchUserPosts();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              _user?.name ?? '',
              style: TextStyle(
                fontSize: 30,
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
                        // Example data (replace with actual data)
                        Row(
                          children: [
                            Text('100',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Posts'),
                          ],
                        ),
                        Row(
                          children: [
                            Text('200',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Followers'),
                          ],
                        ),
                        Row(
                          children: [
                            Text('150',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white60,
                          minimumSize: const Size(160, 40),
                        ),
                        child: const Text('Profile Edit',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white60,
                          minimumSize: const Size(160, 40),
                        ),
                        child: const Text('Profile Share',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return _posts.isEmpty
        ? Center(child: Text('No posts available'))
        : GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        print('Post image URL: ${_posts[index].imageUrl}');  // デバッグ用ログ
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(
                  post: _posts[index],
                  user: _user!,
                ),
              ),
            );
          },
          child: Image.network(
            _posts[index].imageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

}
