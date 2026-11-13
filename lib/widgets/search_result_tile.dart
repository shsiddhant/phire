/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../models/search.dart';

final DateFormat timestampFormat = DateFormat('dd/MM/yyyy, HH:mm');

class SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final snippetText = _getSnippet(result.messageText, query, maxChars: 70);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final snippetStyle = textTheme.bodyMedium ?? const TextStyle();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    result.sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatTimestamp(result.timestamp),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildHighlightedText(
              text: snippetText,
              query: query,
              baseStyle: snippetStyle.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              highlightStyle: snippetStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSnippet(String text, String query, {int maxChars = 60}) {
    if (query.isEmpty || text.length <= maxChars) {
      return text;
    }

    final loweredText = text.toLowerCase();
    final loweredQuery = query.toLowerCase();
    final index = loweredText.indexOf(loweredQuery);

    if (index == -1) {
      return '${text.substring(0, maxChars)}...';
    }

    if (query.length >= maxChars) {
      return '...${text.substring(index, index + maxChars)}...';
    }

    final remainingChars = maxChars - query.length;
    final halfPadding = remainingChars ~/ 2;

    int start = index - halfPadding;
    int end = index + query.length + halfPadding;

    if (start < 0) {
      end += -start;
      start = 0;
    }
    if (end > text.length) {
      start -= (end - text.length);
      end = text.length;
      start = start < 0 ? 0 : start;
    }

    final prefix = start > 0 ? '...' : '';
    final suffix = end < text.length ? '...' : '';

    return '$prefix${text.substring(start, end)}$suffix';
  }

  Widget _buildHighlightedText({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final loweredText = text.toLowerCase();
    final loweredQuery = query.toLowerCase();

    List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index = loweredText.indexOf(loweredQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }

      final matchEnd = index + query.length;
      spans.add(
        TextSpan(text: text.substring(index, matchEnd), style: highlightStyle),
      );

      start = matchEnd;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return timestampFormat.format(timestamp);
  }
}
