import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/talk_room.dart';
import 'package:sms/pages/talk_room_page.dart';
import 'package:sms/pages/search_page.dart';
import 'package:sms/utils/shared_prefs.dart';

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    printUid();
  }

  void printUid() async {
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
                    if (talkRooms.isEmpty) {
                      return Center(child: Text("No talk rooms available."));
                    } else {
                      return ListView.builder(
                        itemCount: talkRooms.length,
                        itemBuilder: (context, index) {
                          var talkUser = talkRooms[index].talkUser;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TalkRoomPage(talkRoom: talkRooms[index]),
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
                                      backgroundImage: talkUser.imagePath != null
                                          ? NetworkImage(talkUser.imagePath!)
                                          : const AssetImage('lib/images/default_avatar.png') as ImageProvider,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        talkUser.name ?? '',  // Handle nullable name
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
                    }
                  } else {
                    return Center(child: Text("Failed to fetch talk rooms."));
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
