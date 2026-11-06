/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import '../models/search.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> search({
    required int conversationId,
    required String query,
    SearchSort sortOrder = SearchSort.oldestFirst,
    int limit = 50,
    int offset = 0,
  });
}
