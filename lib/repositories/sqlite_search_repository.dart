/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:drift/drift.dart';

import '../models/search.dart';
import '../storage/database.dart';
import 'abstract_search_repository.dart';

class SqliteSearchRepository implements SearchRepository {
  final AppDatabase db;

  SqliteSearchRepository(this.db);

  @override
  Future<List<SearchResult>> search({
    required int conversationId,
    required String query,
    SearchSort sortOrder = SearchSort.oldestFirst,
    int limit = 50,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final messages = await _searchMessages(
      conversationId: conversationId,
      query: query,
      sortOrder: sortOrder,
      limit: limit,
      offset: offset,
    );

    return messages
        .map(
          (m) => SearchResult(
            messageId: m.id,
            sender: m.sender,
            timestamp: m.timestamp,
            messageText: m.messageText,
          ),
        )
        .toList();
  }

  String _cleanLikeQuery(String query) {
    return query
        .replaceAll(r'\', r'\\')
        .replaceAll(r'%', r'\%')
        .replaceAll(r'_', r'\_');
  }

  Future<List<MessageData>> _searchMessages({
    required int conversationId,
    required String query,
    required SearchSort sortOrder,
    required int limit,
    required int offset,
  }) async {
    final cleanQuery = _cleanLikeQuery(query);

    final matchExpression = '%$cleanQuery%';

    Expression<bool> filter($MessagesTable tbl) =>
        tbl.conversationId.equals(conversationId) &
        tbl.messageText.like(matchExpression, escapeChar: r'\');

    final queryStmt = db.select(db.messages)
      ..where(filter)
      ..limit(limit, offset: offset);

    queryStmt.orderBy([
      (tbl) {
        switch (sortOrder) {
          case SearchSort.newestFirst:
            return OrderingTerm.desc(tbl.timestamp);
          default:
            return OrderingTerm.asc(tbl.timestamp);
        }
      },
      (tbl) {
        switch (sortOrder) {
          case SearchSort.newestFirst:
            return OrderingTerm.desc(tbl.id);
          default:
            return OrderingTerm.asc(tbl.id);
        }
      },
    ]);

    return await queryStmt.get();
  }
}
