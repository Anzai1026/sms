import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/message.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sms/model/talk_room.dart';
import 'package:sms/utils/shared_prefs.dart';

import '../firestore/user_firestore.dart';
import '../model/user.dart';

class TalkRoomPage extends StatefulWidget {
  final TalkRoom talkRoom;
  const TalkRoomPage(this.talkRoom, {Key? key}) : super(key: key);

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
    String? recipientUid = widget.talkRoom.talkUser.uid;
    if (recipientUid != null) {
      User? recipientUser = await UserFirestore.fetchProfile(recipientUid);
      if (recipientUser != null) {
        setState(() {
          recipientProfileImageUrl = recipientUser.imagePath;
        });
      }
    }
  }

  String formatDate(DateTime date) {
    return intl.DateFormat('yyyy-MM-dd').format(date);
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
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text(widget.talkRoom.talkUser.name),
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
                        message: data['message'],
                        isMe: SharedPrefs.fetchUid() == data['sender_id'],
                        sendTime: data['send_time'],
                        replyToMessage: data['reply_to_message'] ?? '',
                      );

                      final bool isRecipientMessage = widget.talkRoom.talkUser.uid == data['sender_id'];

                      final DateTime currentMessageDate = message.sendTime.toDate();
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
                                            leading: const Icon(Icons.delete),
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
                                      color: message.isMe ? Colors.greenAccent : Colors.white,
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
                                        Text(message.message),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    intl.DateFormat('HH.mm').format(message.sendTime.toDate()),
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
                  color: Colors.grey.shade200,
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
                color: Colors.white,
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            contentPadding: EdgeInsets.only(left: 15),
                            border: OutlineInputBorder(),
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
                      ),
                      style: IconButton.styleFrom(
                        foregroundColor: colors.onPrimary,
                        backgroundColor: colors.primary,
                        disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
                        hoverColor: colors.onPrimary.withOpacity(0.08),
                        focusColor: colors.onPrimary.withOpacity(0.12),
                        highlightColor: colors.onPrimary.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
