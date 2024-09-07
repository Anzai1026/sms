import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/model/user.dart';
import 'package:sms/pages/todo_page.dart';
import 'package:sms/pages/userprofile_page.dart';
import 'account_page.dart';
import 'home_page.dart';
import 'main_layout.dart'; // Import the MainLayout

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
          imagePath: data['image_path'], email: '',
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
                      title: Text(user.name ?? ''),
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
      ),
    );
  }
}
