/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';

import '../controllers/search_controller.dart';
import '../models/search.dart';
import '../widgets/generic/scrollable_page_view.dart';
import '../widgets/search_result_tile.dart';

class SearchView extends StatefulWidget {
  final int conversationId;
  final AppSearchController searchController;

  const SearchView({
    super.key,
    required this.conversationId,
    required this.searchController,
  });

  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController _textController;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.searchController.currentQuery,
    );
    _showClearButton = _textController.text.isNotEmpty;
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  Widget _buildResult(BuildContext context, SearchResult result) {
    return SearchResultTile(
      result: result,
      query: widget.searchController.currentQuery,
      onTap: () {
        Navigator.pop(context, result);
      },
    );
  }

  Widget _buildPageContent() {
    final controller = widget.searchController;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(child: Text('Error: ${controller.error}'));
    }

    final page = controller.currentPage;

    if (page == null) {
      return const Center(child: Text('Search messages in this conversation'));
    }

    if (page.items.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ScrollablePageView<SearchPage, SearchResult>(
      page: page,
      itemWidgetBuilder: _buildResult,
    );
  }

  Widget _buildSearchToolbar(
    BuildContext context,
    AppSearchController searchController,
  ) {
    final sortOrder = searchController.sortOrder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            'Search results',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          TextButton.icon(
            label: Text(
              sortOrder == .oldestFirst ? 'Oldest first' : 'Newest first',
            ),
            onPressed: searchController.isLoading
                ? null
                : () {
                    final SearchSort nextSort =
                        searchController.sortOrder == .oldestFirst
                        ? .newestFirst
                        : .oldestFirst;
                    searchController.updateSort(nextSort);
                  },
            icon: Icon(
              sortOrder == .oldestFirst
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
          ),
        ],
      ),
    );
  }

  void _search() {
    widget.searchController.doSearch(query: _textController.text);
  }

  void _clearSearch() {
    _textController.clear();
    widget.searchController.clearSearch();
  }

  void _goToPage(int pageIndex) {
    widget.searchController.goToPage(pageIndex);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final searchController = widget.searchController;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: TextField(
          controller: _textController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: TextStyle(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showClearButton)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: colorScheme.onPrimaryContainer,
                    onPressed: _clearSearch,
                  ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: colorScheme.onPrimaryContainer,
                  onPressed: _search,
                ),
              ],
            ),
          ),
          onSubmitted: (value) {
            searchController.doSearch(query: value);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListenableBuilder(
          listenable: searchController,
          builder: (context, child) {
            final page = searchController.currentPage;
            final isLoading = searchController.isLoading;
            final hasResults =
                searchController.currentQuery.isNotEmpty &&
                page != null &&
                page.items.isNotEmpty;

            return SizedBox.expand(
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (hasResults) ...[
                        _buildSearchToolbar(context, searchController),
                        const Divider(height: 1),
                      ],
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 80,
                            top: 8,
                            left: 20,
                            right: 20,
                          ),
                          child: _buildPageContent(),
                        ),
                      ),
                    ],
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
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed:
                                      page != null &&
                                          page.pageNumber > 1 &&
                                          !isLoading
                                      ? () => _goToPage(page.pageNumber - 2)
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed:
                                      page != null && page.hasMore && !isLoading
                                      ? () => _goToPage(page.pageNumber)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
