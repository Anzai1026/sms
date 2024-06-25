import 'package:flutter/material.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/model/message.dart';

class MessageWidget extends StatelessWidget {
  final String roomId;
  final Message message;

  const MessageWidget({
    Key? key,
    required this.roomId,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.message),
      subtitle: Text('Sent on: ${message.sendTime}'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await RoomFirestore.deleteMessage(roomId, message.id); // Assuming message has an id field
        },
      ),
    );
  }
}
