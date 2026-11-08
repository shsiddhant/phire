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

  static const int _pageSize = 50;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  SearchSort _sortOrder = SearchSort.oldestFirst;

  SearchPage? _currentPage;
  SearchPage? get currentPage => _currentPage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  int _requestId = 0;

  Future<void> doSearch({
    required int conversationId,
    required String query,
    SearchSort sortOrder = SearchSort.oldestFirst,
  }) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) return;

    _currentQuery = trimmedQuery;
    _sortOrder = sortOrder;

    await _loadPage(conversationId: conversationId, pageIndex: 0);
  }

  Future<void> goToPage({
    required int conversationId,
    required int pageIndex,
  }) async {
    if (_isLoading || pageIndex < 0) return;

    await _loadPage(conversationId: conversationId, pageIndex: pageIndex);
  }

  Future<void> _loadPage({
    required int conversationId,
    required int pageIndex,
  }) async {
    final requestId = ++_requestId;
    final query = _currentQuery;
    final sortOrder = _sortOrder;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _searchRepository.search(
        conversationId: conversationId,
        query: query,
        sortOrder: sortOrder,
        limit: _pageSize + 1,
        offset: pageIndex * _pageSize,
      );

      if (requestId != _requestId) return;

      final hasMore = results.length > _pageSize;
      final items = results.take(_pageSize).toList();

      _currentPage = SearchPage(
        items: items,
        pageNumber: pageIndex + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e;
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _requestId++;
    _currentQuery = '';
    _currentPage = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
