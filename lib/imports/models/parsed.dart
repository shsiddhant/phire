import 'package:intl/intl.dart';


final DateFormat whatsAppDateFormat = DateFormat('dd/MM/yy, HH:mm');

class ParsedLine {
  String timestamp;
  String sender;
  String text;
  bool hasAttachment;

  ParsedLine({
    required this.timestamp,
    required this.sender,
    required this.text,
    required this.hasAttachment,
  });

  String? get attachment =>
      hasAttachment ? text.split(' (file attached)').first : null;

  @override
  String toString() {
    return 'ParsedLine(timestamp: $timestamp, sender: $sender, text: $text, hasAttachment: $hasAttachment)';
  }
}

class ParsedMessage {
  DateTime timestamp;
  String sender;
  String text;
  String? attachment;

  ParsedMessage({
    required this.timestamp,
    required this.sender,
    required this.text,
    required this.attachment,
  });

  factory ParsedMessage.fromParsedLine(ParsedLine parsedLine) {
    return ParsedMessage(
      timestamp: whatsAppDateFormat.parseStrict(parsedLine.timestamp),
      sender: parsedLine.sender,
      text: parsedLine.text,
      attachment: parsedLine.attachment,
    );
  }

  @override
  String toString() {
    return 'ParsedMessage(timestamp: $timestamp, sender: $sender, text: $text, attachment: $attachment)';
  }
}