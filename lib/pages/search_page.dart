import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/model/user.dart';

import 'account_page.dart';
import 'home_page.dart';


class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<User> searchResults = []; // 検索結果を保持するリスト
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      print('Searching for: $query'); // デバッグ用メッセージ

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      List<User> users = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return User(
          name: data['name'] ?? '',
          id: doc.id, // FirestoreのドキュメントIDをUIDとして使用
          imagePath: data['image_path'],
        );
      }).toList();

      setState(() {
        searchResults = users;
      });

      print('Search results: $users'); // デバッグ用メッセージ

    } catch (e) {
      print('Error searching users: $e');
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
                onPressed: () {
                  Navigator.push(
                    context,
                    NoAnimationPageRoute(builder: (context) => SearchPage()),
                  );
                },
              ),
              GButton(
                icon: Icons.slow_motion_video,
                text: 'Reals',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    NoAnimationPageRoute(builder: (context) => AccountPage()),
                  );
                },
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter user name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String searchQuery = _searchController.text.trim();
                    if (searchQuery.isNotEmpty) {
                      _performSearch(searchQuery);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  User user = searchResults[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.id), // ユーザーのUIDを表示
                    leading: user.imagePath != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(user.imagePath!),
                    )
                        : CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(user: user),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(user.name),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              user.imagePath != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(user.imagePath!),
                radius: 50,
              )
                  : CircleAvatar(
                child: Icon(Icons.person, size: 50),
                radius: 50,
              ),
              SizedBox(height: 20),
              Text(user.name, style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Text(user.id, style: TextStyle(fontSize: 16, color: Colors.grey)), // UIDを表示
            ],
          ),
        ),
      ),
    );
  }
}
