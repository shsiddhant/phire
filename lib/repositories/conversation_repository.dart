/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:drift/drift.dart';

import '../exceptions/conversation_already_exists.dart';
import '../models/conversation.dart';
import '../storage/database.dart';
import '../storage/drift_exception_extensions.dart';

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

  // Reading progress
  Future<void> updateReadingProgress({
    required int conversationId,
    required int messageId,
  }) async {
    await db
        .into(db.readingProgress)
        .insertOnConflictUpdate(
          ReadingProgressCompanion(
            conversationId: Value(conversationId),
            messageId: Value(messageId),
          ),
        );
  }

  Future<ReadingProgressData?> getReadingProgress(int conversationId) async {
    return await (db.select(db.readingProgress)
          ..where((tbl) => tbl.conversationId.equals(conversationId)))
        .getSingleOrNull();
  }

  // Delete conversation
  Future<int> deleteConversation(int id) async {
    return (db.delete(
      db.conversations,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  // Rename conversation
  Future<int> renameConversation({
    required int id,
    required String newTitle,
  }) async {
    try {
      return await (db.update(db.conversations)
            ..where((tbl) => tbl.id.equals(id)))
          .write(ConversationsCompanion(title: Value(newTitle)));
    } on Exception catch (e) {
      if (e.isUniqueConstraint) {
        throw const ConversationAlreadyExistsException();
      }
      rethrow;
    }
  }
}
