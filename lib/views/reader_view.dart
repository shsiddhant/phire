import 'package:flutter/material.dart';
import '../models/conversation_page.dart';
import 'conversation_page_view.dart';

class ReaderView extends StatefulWidget {
  final String conversationTitle;
  final int totalPages;
  final Future<ConversationPage> Function(int pageIndex) fetchPage;

  const ReaderView({
    super.key,
    required this.conversationTitle,
    required this.totalPages,
    required this.fetchPage,
  });

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  int _activePageIndex = 0;

  ConversationPage? _currentPage;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  Future<void> _loadPage(int pageIndex) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await widget.fetchPage(pageIndex);

      if (!mounted) return;

      setState(() {
        _activePageIndex = pageIndex;
        _currentPage = page;
        _loading = false;
      });
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

    return ConversationPageView(page: page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.conversationTitle),
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
