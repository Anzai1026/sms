import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/user.dart';
import 'package:sms/pages/drawer.dart';
import 'package:sms/utils/shared_prefs.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkFollowing();
  }

  Future<void> _fetchUserProfile() async {
    String? uid = await SharedPrefs.getUid();
    if (uid != null) {
      User? user = await UserFirestore.fetchProfile(uid);
      if (user != null) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  Future<void> _checkFollowing() async {
    String? loginUid = await SharedPrefs.getUid();
    if (loginUid != null && _user != null) {
      bool isFollowing = await UserFirestore.isFollowing(loginUid, _user!.uid);
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  Future<void> _toggleFollow() async {
    String? loginUid = await SharedPrefs.getUid();
    if (loginUid != null && _user != null) {
      if (_isFollowing) {
        await UserFirestore.unfollow(loginUid, _user!.uid);
      } else {
        await UserFirestore.follow(loginUid, _user!.uid);
      }
      setState(() {
        _isFollowing = !_isFollowing;
      });
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
                  Navigator.push(
                    context,
                    NoAnimationPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
              GButton(
                icon: Icons.slow_motion_video,
                text: 'Reals',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
                onPressed: () {},
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('100', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Posts'),
                  ],
                ),
                Column(
                  children: [
                    Text('200', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Followers'),
                  ],
                ),
                Column(
                  children: [
                    Text('150', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Following'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //   child: ElevatedButton(
          //     onPressed: _toggleFollow,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
          //       minimumSize: const Size(double.infinity, 36),
          //     ),
          //     child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
          //   ),
          // ),
          // const SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //   child: Text(
          //     _user?.uid ?? 'This is a bio.',
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // const SizedBox(height: 20),
          // GridView.builder(
          //   physics: NeverScrollableScrollPhysics(),
          //   shrinkWrap: true,
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 3,
          //     crossAxisSpacing: 2,
          //     mainAxisSpacing: 2,
          //   ),
          //   itemCount: 30, // Replace with the actual number of posts
          //   itemBuilder: (context, index) {
          //     return Container(
          //       color: Colors.grey.shade300,
          //       child: Image.network(
          //         'https://example.com/post_image.jpg',
          //         fit: BoxFit.cover,
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
