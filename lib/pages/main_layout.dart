import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'todo_page.dart';
import 'account_page.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  const MainLayout({Key? key, required this.child, this.selectedIndex = 0}) : super(key: key);
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (!mounted) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, NoAnimationPageRoute(builder: (_) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, NoAnimationPageRoute(builder: (_) => SearchPage()));
        break;
      // case 2:
      //   Navigator.pushReplacement(context, NoAnimationPageRoute(builder: (_) => TodoPage()));
      //   break;
      case 2:
        Navigator.pushReplacement(context, NoAnimationPageRoute(builder: (_) => AccountPage()));
        break;
    }
  }

  @override
  void dispose() {
    // リソースのクリーンアップをここで行います。
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
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
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
