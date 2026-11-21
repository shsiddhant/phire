/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';

import '../models/search.dart';
import '../repositories/abstract_search_repository.dart';

class AppSearchController extends ChangeNotifier {
  final SearchRepository _searchRepository;
  final int conversationId;

  AppSearchController({
    required this.conversationId,
    required this._searchRepository,
  });

  static const int _pageSize = 50;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  SearchSort _sortOrder = SearchSort.oldestFirst;
  SearchSort get sortOrder => _sortOrder;

  SearchPage? _currentPage;
  SearchPage? get currentPage => _currentPage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  int _requestId = 0;

  Future<void> updateSort(SearchSort newSortOrder) async {
    if (_sortOrder == newSortOrder) return;
    _sortOrder = newSortOrder;

    if (_currentQuery.isEmpty) {
      notifyListeners();
      return;
    }
    await doSearch(query: _currentQuery);
  }

  Future<void> doSearch({required String query, SearchSort? sortOrder}) async {
    final trimmedQuery = query.trim();

    if (sortOrder != null) {
      _sortOrder = sortOrder;
    }

    if (trimmedQuery.isEmpty) {
      clearSearch();
      return;
    }

    _currentQuery = trimmedQuery;

    await _loadPage(0);
  }

  Future<void> goToPage(int pageIndex) async {
    if (_isLoading || pageIndex < 0) return;

    await _loadPage(pageIndex);
  }

  Future<void> _loadPage(int pageIndex) async {
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
