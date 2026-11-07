/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:flutter/material.dart';

import '../models/search.dart';
import '../repositories/abstract_search_repository.dart';

class AppSearchController extends ChangeNotifier {
  final SearchRepository _searchRepository;

  AppSearchController(this._searchRepository);

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  List<SearchResult> _results = [];
  List<SearchResult> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  Future<void> doSearch({
    required int conversationId,
    required String query,
    SearchSort sortOrder = SearchSort.oldestFirst,
    int limit = 50,
    int offset = 0,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return;
    }

    _currentQuery = trimmedQuery;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _searchRepository.search(
        conversationId: conversationId,
        query: _currentQuery,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      _error = e;
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _currentQuery = '';
    _results = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
