import 'package:flutter/material.dart';
import '../widgets/message_tile.dart';
import '../models/conversation_page.dart';

class ConversationPageView extends StatefulWidget {
  final ConversationPage page;

  const ConversationPageView({super.key, required this.page});

  @override
  State<StatefulWidget> createState() => _ConversationPageView();
}

class _ConversationPageView extends State<ConversationPageView> {
  late final ScrollController _scrollController;

  bool get _showTopFade =>
      _scrollController.hasClients && _scrollController.offset > 0;

  bool get _showBottomFade =>
      _scrollController.hasClients &&
      _scrollController.position.maxScrollExtent > 0 &&
      _scrollController.offset < _scrollController.position.maxScrollExtent;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final listview = ListView.builder(
      controller: _scrollController,
      itemCount: widget.page.messages.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (BuildContext context, int index) {
        final messageRepr = widget.page.messages[index];
        return MessageTile(messageRepr: messageRepr);
      },
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
