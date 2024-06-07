import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/message.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sms/model/talk_room.dart';
import 'package:sms/utils/shared_prefs.dart';

class TalkRoomPage extends StatefulWidget {
  final TalkRoom talkRoom;
  const TalkRoomPage(this.talkRoom, {Key? key}) : super(key: key);

  @override
  State<TalkRoomPage> createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
              if(snapshot.hasData) {
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
                            message: data['message'],
                            isMe: SharedPrefs.getUid() == data['sender_id'],
                            sendTime: data['send_time']
                        );
                        return Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: index == 0 ? 10 : 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            textDirection: message.isMe ? TextDirection.rtl : TextDirection.ltr,
                            children: [
                              Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                  decoration: BoxDecoration(
                                    color: message.isMe ? Colors.greenAccent : Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Text(message.message)
                              ),
                              Text(intl.DateFormat('HH.mm').format(message.sendTime.toDate()),style: const TextStyle(fontWeight: FontWeight.w500))
                            ],
                          ),
                        );
                      }
                  ),
                );
              } else {
                return const Center(child: Text('メッセージがありません'),);
              }
            }
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: Colors.white,
                height: 60,
                child: Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: 'Type a message',
                          contentPadding: EdgeInsets.only(left: 15),
                          border: OutlineInputBorder()
                        ),
                      ),
                    )),
                    IconButton(
                        onPressed: () async{
                          await RoomFirestore.sendMessage(
                              roomId: widget.talkRoom.roomId,
                              message: controller.text
                          );
                          controller.clear();
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.greenAccent,
                          size: 40.0,
                        ))
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          )
        ],
      ),
    );
  }
}
