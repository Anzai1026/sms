import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String message;
  final bool isMe;
  final Timestamp sendTime;
  final String replyToMessage;

  Message({
    required this.id,
    required this.message,
    required this.isMe,
    required this.sendTime,
    this.replyToMessage = '',
  });
}
