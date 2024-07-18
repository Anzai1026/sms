import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/message.dart';
import 'package:intl/intl.dart' as intl; // Importing intl package with an alias
import 'package:sms/model/talk_room.dart';
import 'package:sms/utils/shared_prefs.dart';

import '../firestore/user_firestore.dart';
import '../model/user.dart';

class TalkRoomPage extends StatefulWidget {
  final TalkRoom talkRoom;

  const TalkRoomPage({Key? key, required this.talkRoom}) : super(key: key);

  @override
  State<TalkRoomPage> createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  final TextEditingController controller = TextEditingController();
  String? recipientProfileImageUrl;
  Message? replyMessage;

  @override
  void initState() {
    super.initState();
    fetchRecipientProfileImage();
  }

  Future<void> fetchRecipientProfileImage() async {
    String? recipientUid = widget.talkRoom.talkUser.id;
    if (recipientUid != null) {
      User? recipientUser = await UserFirestore.fetchProfile(recipientUid);
      if (recipientUser != null) {
        setState(() {
          recipientProfileImageUrl = recipientUser.imagePath;
        });
      }
    }
  }

  String formatDate(DateTime dateTime) {
    return intl.DateFormat('yyyy-MM-dd').format(dateTime);
  }

  bool isNewDay(DateTime current, DateTime previous) {
    return formatDate(current) != formatDate(previous);
  }

  Future<void> deleteMessage(String messageId) async {
    await RoomFirestore.deleteMessage(widget.talkRoom.roomId, messageId);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.talkRoom.talkUser.name ?? '', // Handling null with null-aware operator
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: RoomFirestore.fetchMessageSnapshot(widget.talkRoom.roomId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: ListView.builder(
                    physics: const RangeMaintainingScrollPhysics(),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      final Message message = Message(
                        id: doc.id,
                        message: data['message'] ?? '', // Handling null with null-aware operator
                        isMe: SharedPrefs.fetchUid() == data['sender_id'],
                        sendTime: (data['send_time'] as Timestamp).toDate(), // Converting Timestamp to DateTime
                        replyToMessage: data['reply_to_message'] ?? '',
                      );

                      final DateTime currentMessageDate = message.sendTime;
                      bool showDateHeader = false;
                      if (index == snapshot.data!.docs.length - 1) {
                        showDateHeader = true;
                      } else {
                        final previousDoc = snapshot.data!.docs[index + 1];
                        final Map<String, dynamic> previousData = previousDoc.data() as Map<String, dynamic>;
                        final DateTime previousMessageDate = (previousData['send_time'] as Timestamp).toDate();
                        showDateHeader = isNewDay(currentMessageDate, previousMessageDate);
                      }

                      return Column(
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                intl.DateFormat('yyyy-MM-dd').format(currentMessageDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ),
                          GestureDetector(
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: const Icon(Icons.reply),
                                          title: const Text('Reply'),
                                          onTap: () {
                                            setState(() {
                                              replyMessage = message;
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      if (message.isMe)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            leading: const Icon(Icons.delete, color: Colors.red),
                                            title: const Text('Delete'),
                                            onTap: () {
                                              deleteMessage(message.id);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 10.0,
                                left: 10,
                                right: 10,
                                bottom: index == 0 ? 10 : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                textDirection: message.isMe ? TextDirection.rtl : TextDirection.ltr,
                                children: [
                                  if (!message.isMe && recipientProfileImageUrl != null)
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(recipientProfileImageUrl!),
                                      radius: 15,
                                    ),
                                  Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                    decoration: BoxDecoration(
                                      color: message.isMe ? Colors.blue : Colors.black12,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (message.replyToMessage.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                            margin: const EdgeInsets.only(bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              message.replyToMessage,
                                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                                            ),
                                          ),
                                        Text(
                                          message.message,
                                          style: TextStyle(
                                            color: message.isMe ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    intl.DateFormat('HH.mm').format(message.sendTime as DateTime),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Text('メッセージがありません'),
                );
              }
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (replyMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12, // 枠線の色を設定
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Replying to: ${replyMessage!.message}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            replyMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Container(
                color: Colors.deepPurple[50],
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Aa',
                            fillColor: Colors.black12,
                            filled: true,
                            contentPadding: EdgeInsets.only(left: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await RoomFirestore.sendMessage(
                          roomId: widget.talkRoom.roomId,
                          message: controller.text,
                          replyToMessage: replyMessage?.message ?? '',
                        );
                        controller.clear();
                        setState(() {
                          replyMessage = null;
                        });
                      },
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 40.0,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.deepPurple[50],
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
