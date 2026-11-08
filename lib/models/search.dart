/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'abstract_page.dart';

class SearchResult {
  final int messageId;
  final String sender;
  final DateTime timestamp;
  final String messageText;

  const SearchResult({
    required this.messageId,
    required this.sender,
    required this.timestamp,
    required this.messageText,
  });
}

enum SearchSort { newestFirst, oldestFirst, relevance }

class SearchPage extends BasePage<SearchResult> {
  SearchPage({
    required super.items,
    required super.pageNumber,
    required super.hasMore,
  });
}
