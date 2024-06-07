import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/model/user.dart';
import 'package:sms/pages/drawer.dart';
import 'package:sms/pages/setting_profile_page.dart';
import 'package:sms/utils/shared_prefs.dart';

import 'home_page.dart';
import 'message_page.dart';

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
  bool _isFollowing = false; // フォローしているかどうかの状態
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
    _checkFollowing(); // フォロー状態をチェック
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
    // ログインユーザーが表示されているユーザーをフォローしているかをチェック
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
        // フォローを解除
        await UserFirestore.unfollow(loginUid, _user!.uid);
      } else {
        // フォローする
        await UserFirestore.follow(loginUid, _user!.uid);
      }
      // フォロー状態を更新
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
                icon: Icons.slow_motion_video,
                text: 'Reals',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
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
        automaticallyImplyLeading: false, // 戻る矢印を無くす
        title: const Row(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: _user?.imagePath != null
              ? NetworkImage(_user!.imagePath!)
              : const NetworkImage("https://example.com/default.jpg"),
          radius: 50,
        ),
        const SizedBox(height: 20),
        Text(
          _user?.name ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _toggleFollow,
          child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}