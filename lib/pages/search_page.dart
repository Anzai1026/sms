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
  List<User> searchResults = [];
  int _selectedIndex = 1;

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
      if (mounted) {
        setState(() {
          searchResults = [];
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      print('Searching for: $query');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      List<User> users = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return User(
          name: data['name'] ?? '',
          id: doc.id,
          imagePath: data['image_path'],
        );
      }).toList();

      if (mounted) {
        setState(() {
          searchResults = users;
        });
      }

      print('Search results: $users');
    } catch (e) {
      print('Error searching users: $e');
    }
  }

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
                  navigateToPage(HomePage());
                },
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
              GButton(
                icon: Icons.slow_motion_video,
                text: 'Reels',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
                onPressed: () {
                  navigateToPage(AccountPage());
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
        padding: EdgeInsets.all(16.0),
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

  Future<String?> findExistingTalkRoomId(String userId) async {
    // ユーザーごとに保存されているトークルームのIDを検索するロジック
    // ここでFirestoreなどのデータベースからトークルームを検索し、存在する場合はそのIDを返す
    // 存在しない場合はnullを返す
    // 以下は仮の実装例です
    // Firestoreからの実際のクエリなどに置き換えてください
    return 'existing_room_id'; // 例として存在するトークルームIDを返す
  }

  Future<String> createNewTalkRoom(String userId) async {
    // 新しいトークルームを作成するロジック
    // ここでFirestoreなどのデータベースに新しいトークルームを追加し、そのIDを取得する
    // 以下は仮の実装例です
    // Firestoreへの実際のデータの追加などに置き換えてください
    return 'new_room_id'; // 例として新しいトークルームIDを返す
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              SizedBox(height: 10),
              Text(user.id, style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white60,
                        minimumSize: const Size(160, 40),
                      ),
                      child: const Text('Follow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  SizedBox(width: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
