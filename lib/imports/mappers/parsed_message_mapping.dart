import 'package:drift/drift.dart';
import '../models/parsed.dart';
import '../../storage/database.dart';

extension ParsedMessageToCompanion on ParsedMessage {
  MessagesCompanion toCompanion({required int conversationId}) {
    return MessagesCompanion.insert(
      timestamp: timestamp,
      sender: sender,
      messageText: text,
      attachment: Value(attachment),
      conversationId: conversationId,
    );
  }
}
