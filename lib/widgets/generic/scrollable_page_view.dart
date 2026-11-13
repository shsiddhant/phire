/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/abstract_page.dart';

class ScrollablePageView<P extends BasePage<T>, T> extends StatefulWidget {
  final P page;
  final Widget Function(BuildContext context, T item) itemWidgetBuilder;
  final ItemScrollController? itemScrollController;
  final ItemPositionsListener? itemPositionsListener;

  const ScrollablePageView({
    super.key,
    required this.page,
    required this.itemWidgetBuilder,
    this.itemScrollController,
    this.itemPositionsListener,
  });

  @override
  State<ScrollablePageView<P, T>> createState() =>
      _ScrollablePageViewState<P, T>();
}

class _ScrollablePageViewState<P extends BasePage<T>, T>
    extends State<ScrollablePageView<P, T>> {
  late final ItemScrollController _internalScrollController;
  late final ItemPositionsListener _internalPositionsListener;

  bool _showTopFade = false;
  bool _showBottomFade = false;

  @override
  void initState() {
    super.initState();
    _internalScrollController =
        widget.itemScrollController ?? ItemScrollController();
    _internalPositionsListener =
        widget.itemPositionsListener ?? ItemPositionsListener.create();

    _internalPositionsListener.itemPositions.addListener(_updateFadeVisibility);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateFadeVisibility();
    });
  }

  @override
  void dispose() {
    _internalPositionsListener.itemPositions.removeListener(
      _updateFadeVisibility,
    );
    super.dispose();
  }

  void _updateFadeVisibility() {
    final positions = _internalPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return;
    }
    final totalItems = widget.page.items.length;
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

    final newShowTopFade = !isAtAbsoluteTop;
    final newShowBottomFade = !isAtAbsoluteBottom;

    if (_showTopFade != newShowTopFade ||
        _showBottomFade != newShowBottomFade) {
      setState(() {
        _showTopFade = newShowTopFade;
        _showBottomFade = newShowBottomFade;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ScrollablePageView<P, T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset scroll on page turn
    if (widget.itemScrollController == null &&
        widget.page.pageNumber != oldWidget.page.pageNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_internalScrollController.isAttached) {
          _internalScrollController.scrollTo(
            index: 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final listview = ScrollablePositionedList.builder(
      itemCount: widget.page.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.page.items[index];
        return widget.itemWidgetBuilder(context, item);
      },
      itemScrollController: _internalScrollController,
      itemPositionsListener: _internalPositionsListener,
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
