class Message {
  final String id;
  final String message;
  final bool isMe;
  final DateTime sendTime;
  final String replyToMessage;

  Message({
    required this.id,
    required this.message,
    required this.isMe,
    required this.sendTime,
    required this.replyToMessage,
  });
}
