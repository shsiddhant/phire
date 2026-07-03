import 'package:drift/drift.dart';

import '../storage/database.dart';

class MessageRepository {
  final AppDatabase db;
  static const int limit = 10;

  MessageRepository(this.db);

  Future<List<MessageData>> getMessagesByConversationId({
    required int conversationId,
    int limit = limit,
    int offset = 0,
  }) async {
    Expression<bool> idFilter($MessagesTable tbl) =>
        tbl.conversationId.equals(conversationId);
    final queryStmt = db.select(db.messages)
      ..where(idFilter)
      ..limit(limit, offset: offset);
    return await queryStmt.get();
  }

  Future<int?> getMessageCountById({required int conversationId}) async {
    final table = db.messages;
    final countExp = countAll();
    final query = db.selectOnly(table)
      ..addColumns([countExp])
      ..where(table.conversationId.equals(conversationId));

    return await query.map((row) => row.read(countExp)).getSingle();
  }

  Future<int?> getMessageOffsetByTimestamp({
    required int conversationId,
    required DateTime timestamp,
  }) async {
    final table = db.messages;
    final countExp = countAll();
    Expression<bool> idFilter = db.messages.conversationId.equals(
      conversationId,
    );
    Expression<bool> timestampFilter = db.messages.timestamp.isSmallerThanValue(
      timestamp,
    );
    final query = db.selectOnly(table)
      ..addColumns([countExp])
      ..where(idFilter & timestampFilter);

    return await query.map((row) => row.read(countExp)).getSingle();
  }
}
