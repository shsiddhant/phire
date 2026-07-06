import 'package:flutter/material.dart';
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

  bool _showTopFade = false;
  bool _showBottomFade = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_updateFadeVisibility);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_updateFadeVisibility);
    super.dispose();
  }

  void _updateFadeVisibility() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return;
    }
    final totalItems = widget.page.messages.length;
    final firstVisible = positions.reduce(
      (min, p) => p.index < min.index ? p : min,
    );
    final lastVisible = positions.reduce(
      (max, p) => p.index > max.index ? p : max,
    );
    final isAtAbsoluteTop =
        firstVisible.index == 0 && firstVisible.itemLeadingEdge >= 0;

    // itemTrailingEdge >= 1 means the bottom of the item is at or below the bottom viewport edge
    final isAtAbsoluteBottom =
        lastVisible.index == totalItems - 1 &&
        lastVisible.itemTrailingEdge <= 1;

    setState(() {
      _showTopFade = !isAtAbsoluteTop;
      _showBottomFade = !isAtAbsoluteBottom;
    });
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemScrollController.scrollTo(
          index: widget.jumpMessageIndex!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
        return MessageTile(messageRepr: messageRepr);
      },
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
    );
    return Stack(
      children: [
        listview,
        if (_showTopFade)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor, bgColor.withAlpha(0)],
                  ),
                ),
              ),
            ),
          ),
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
