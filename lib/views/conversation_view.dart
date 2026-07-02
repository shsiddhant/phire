import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_tile.dart';

class ConversationView extends StatelessWidget {
  final int conversationId;
  final String conversationTitle;
  final List<MessageRepresentation> messages;

  const ConversationView({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(conversationTitle),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: messages.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int index) {
              return MessageTile(messageRepr: messages[index]);
            },
          ),
        ),
      ),
    );
  }
}
