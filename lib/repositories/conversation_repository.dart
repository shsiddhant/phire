import 'package:drift/drift.dart';

import '../models/conversation.dart';
import '../storage/database.dart';

class ConversationRepository {
  final AppDatabase db;

  ConversationRepository(this.db);

  Future<ConversationData?> getConversationById(int id) async {
    return await (db.select(
      db.conversations,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<ConversationData>> getAllConversations() async {
    return await db.select(db.conversations).get();
  }

  Future<List<ConversationListItem>> getConversationList(int pageSize) async {
    final totalMessagesColumn = db.messages.id.count();
    final query =
        db.select(db.conversations).join([
            leftOuterJoin(
              db.messages,
              db.messages.conversationId.equalsExp(db.conversations.id),
            ),
          ])
          ..addColumns([totalMessagesColumn])
          ..groupBy([db.conversations.id]);

    final rows = await query.get();

    return rows.map((row) {
      return ConversationListItem(
        id: row.readTable(db.conversations).id,
        title: row.readTable(db.conversations).title,
        totalPages: ((row.read(totalMessagesColumn) ?? 0) / pageSize).ceil(),
      );
    }).toList();
  }
}
