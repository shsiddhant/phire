/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:flutter/material.dart';
import '../app_dependencies_injection.dart';
import '../mappers/message_representation_mapper.dart';
import '../models/conversation_page.dart';
import '../models/page_position.dart';
import '../repositories/conversation_repository.dart';
import '../repositories/message_repository.dart';
import '../utils/path_utils.dart';
import 'conversation_page_view.dart';

class ReaderView extends StatefulWidget {
  final int conversationId;
  final String conversationTitle;
  final int totalPages;
  final int initialPageIndex;

  const ReaderView({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
    required this.totalPages,
    required this.initialPageIndex,
  });

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  final int _pageSize = 30;
  final MessageRepository _messageRepository = locator<MessageRepository>();
  final ConversationRepository _conversationRepository =
      locator<ConversationRepository>();

  int _activePageIndex = 0;

  int? _jumpMessageIndex;
  int _jumpToken = 0;

  ConversationPage? _currentPage;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPage(widget.initialPageIndex);
  }

  Future<ConversationPage> _fetchPage({required int pageIndex}) async {
    final int offset = pageIndex * _pageSize;
    final messages = await _messageRepository.getMessagesByConversationId(
      conversationId: widget.conversationId,
      offset: offset,
      limit: _pageSize,
    );
    final conversationMediaPath = await getConversationMediaPath(
      widget.conversationId,
    );
    return ConversationPage(
      pageNumber: pageIndex + 1,
      messages: buildRepresentationFromDb(messages, conversationMediaPath),
    );
  }

  Future<void> _loadPage(int pageIndex) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await _fetchPage(pageIndex: pageIndex);

      if (!mounted) return;

      setState(() {
        _activePageIndex = pageIndex;
        _currentPage = page;
        _loading = false;
      });

      if (page.messages.isNotEmpty) {
        final firstMessageId = page.messages.first.id;
        await _conversationRepository.updateReadingProgress(
          conversationId: widget.conversationId,
          messageId: firstMessageId,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < widget.totalPages) {
      _loadPage(pageIndex);
    }
  }

  Future<void> _jumpToDate() async {
    final selectedTimestamp = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
    );

    if (selectedTimestamp == null) {
      return;
    }

    final offset = await _messageRepository.getMessageOffsetByTimestamp(
      conversationId: widget.conversationId,
      timestamp: selectedTimestamp,
    );

    if (!mounted || offset == null) {
      return;
    }

    final position = PagePosition.fromOffset(
      offset: offset,
      pageSize: _pageSize,
    );

    setState(() {
      _jumpMessageIndex = position.itemIndex;
      _jumpToken++;
    });

    await _loadPage(position.pageIndex);
  }

  Widget _buildPageContent() {
    final page = _currentPage;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (page == null) {
      return const SizedBox.shrink();
    }

    return ConversationPageView(
      page: page,
      jumpMessageIndex: _jumpMessageIndex,
      jumpToken: _jumpToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.conversationTitle),
        actions: [
          IconButton(
            onPressed: _jumpToDate,
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 80, top: 8, left: 20, right: 20),
            child: _buildPageContent(),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.inversePrimary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _activePageIndex > 0
                                ? () => _goToPage(_activePageIndex - 1)
                                : null,
                          ),
                          Text(
                            'Page ${_activePageIndex + 1} / ${widget.totalPages}',
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _activePageIndex < widget.totalPages - 1
                                ? () => _goToPage(_activePageIndex + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
