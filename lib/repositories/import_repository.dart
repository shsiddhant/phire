import 'package:drift/drift.dart';
import '../imports/mappers/parsed_message_mapping.dart';
import '../storage/database.dart';
import '../imports/models/parsed.dart';

class ImportRepository {
  final AppDatabase db;

  ImportRepository(this.db);

  Future<int> createConversation({
    required String title,
    required String source,
  }) async {
    final int conversationId = await db
        .into(db.conversations)
        .insertOnConflictUpdate(
          ConversationsCompanion.insert(title: title, source: Value(source)),
        );
    return conversationId;
  }

  Future<void> insertParsedMessages({
    required int conversationId,
    required Iterable<ParsedMessage> parsedMessages,
  }) async {
    final Iterable<MessagesCompanion> companions = parsedMessages.map(
      (ParsedMessage m) => m.toCompanion(conversationId: conversationId),
    );

    await db.batch((batch) {
      batch.insertAll(db.messages, companions);
    });
  }

  Future<int> importConversation({
    required String title,
    required String source,
    required Stream<List<ParsedMessage>> batches,
  }) async {
    return await db.transaction(() async {
      final int conversationId = await createConversation(
        title: title,
        source: source,
      );
      await for (final batch in batches) {
        await insertParsedMessages(
          conversationId: conversationId,
          parsedMessages: batch,
        );
      }

      return conversationId;
    });
  }
}
