class Message {
  final DateTime timestamp;
  final String sender;
  final String text;
  final String? attachment;

  Message({
    required this.timestamp,
    required this.sender,
    required this.text,
    this.attachment,
  });

  factory Message.fromJson({required Map<String, dynamic> json}) {
    return Message(
      timestamp: DateTime.parse(json['timestamp']),
      sender: json['sender'],
      text: json['text'],
      attachment: json['attachment'],
    );
  }

  @override
  String toString() {
    return 'Message(timestamp: ${timestamp.toLocal()}, '
        'sender: $sender, text: $text, attachment: $attachment)';
  }
}

class MessageRepresentation {
  final String formattedTime;
  final String senderName;
  final String messageText;
  final String? attachmentFilePath;
  final bool renderAttachment;
  final bool showSenderHeader;
  final bool isFirstOfDay;
  final String? dayMarker;

  MessageRepresentation({
    required this.formattedTime,
    required this.senderName,
    required this.messageText,
    this.attachmentFilePath,
    required this.renderAttachment,
    required this.showSenderHeader,
    required this.isFirstOfDay,
    this.dayMarker,
  });
}
