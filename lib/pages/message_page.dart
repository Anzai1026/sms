import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sms/pages/drawer.dart';
import 'package:sms/pages/search_page.dart';
import 'package:sms/pages/talk_room_page.dart';
import '../firestore/room_firestore.dart';
import '../model/talk_room.dart';
import '../utils/shared_prefs.dart';
import 'account_page.dart';
import 'home_page.dart';

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void print_uid() async {
    final uid = user.uid;
    await SharedPrefs.setUid(uid);
    print("uid is here : $uid");
  }

  void navigateToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print_uid();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Center(
              child: Text(
                'ALIEN.',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              navigateToPage(SearchPage());
            },
          ),
          // 他のアクションアイコンを追加できます
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: RoomFirestore.joinedRoomSnapshot,
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasData) {
            return FutureBuilder<List<TalkRoom>?>(
              future: RoomFirestore.fetchJoinedRooms(streamSnapshot.data!),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (futureSnapshot.hasData) {
                    List<TalkRoom> talkRooms = futureSnapshot.data!;
                    return ListView.builder(
                      itemCount: talkRooms.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TalkRoomPage(talkRooms[index]),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 70,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: talkRooms[index].talkUser.imagePath == null
                                        ? null
                                        : NetworkImage(talkRooms[index].talkUser.imagePath!),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      talkRooms[index].talkUser.name,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    Text(
                                      talkRooms[index].lastMessage ?? '',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("LOGGED IN AS ${user.email!}"));
                  }
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}