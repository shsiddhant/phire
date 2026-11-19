/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../widgets/message_tile.dart';
import '../models/conversation_page.dart';

class ConversationPageView extends StatefulWidget {
  final ConversationPage page;
  final int? jumpMessageIndex;
  final int jumpToken;

  const ConversationPageView({
    super.key,
    required this.page,
    this.jumpMessageIndex,
    required this.jumpToken,
  });

  @override
  State<StatefulWidget> createState() => _ConversationPageView();
}

class _ConversationPageView extends State<ConversationPageView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _showBottomFade = false;
  Timer? _highlightTimer;
  int? _highlightedMessageId;

  void _triggerHighlight(int messageId) {
    _highlightTimer?.cancel();
    setState(() => _highlightedMessageId = messageId);

    _highlightTimer = Timer(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      setState(() => _highlightedMessageId = null);
    });
  }

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_updateFadeVisibility);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_updateFadeVisibility);
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _updateFadeVisibility() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return;
    }
    final totalItems = widget.page.messages.length;
    final lastVisible = positions.reduce(
      (max, p) => p.index > max.index ? p : max,
    );

    // itemTrailingEdge >= 1 means the bottom of the item is at or below the bottom viewport edge
    final isAtAbsoluteBottom =
        lastVisible.index == totalItems - 1 &&
        lastVisible.itemTrailingEdge <= 1;

    final nextBottomFade = !isAtAbsoluteBottom;

    if (_showBottomFade != nextBottomFade) {
      setState(() {
        _showBottomFade = nextBottomFade;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ConversationPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset scroll on page turn
    if (widget.page.pageNumber != oldWidget.page.pageNumber) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        _itemScrollController.scrollTo(
          index: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }

    // Scroll to message on jump to message index trigger from parent (ReaderView)
    if (widget.jumpToken != oldWidget.jumpToken &&
        widget.jumpMessageIndex != null) {
      final targetIndex = widget.jumpMessageIndex!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _itemScrollController.scrollTo(
          index: targetIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        if (!mounted || widget.page.messages.isEmpty) return;

        final highlightIndex = targetIndex.clamp(
          0,
          widget.page.messages.length - 1,
        );
        _triggerHighlight(widget.page.messages[highlightIndex].id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final listview = ScrollablePositionedList.builder(
      itemCount: widget.page.messages.length,
      itemBuilder: (BuildContext context, int index) {
        final messageRepr = widget.page.messages[index];
        final isHighlighted = _highlightedMessageId == messageRepr.id;
        return MessageTile(
          messageRepr: messageRepr,
          isHighlighted: isHighlighted,
        );
      },
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
    );
    return Stack(
      children: [
        listview,
        if (_showBottomFade)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [bgColor, bgColor.withAlpha(0)],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
