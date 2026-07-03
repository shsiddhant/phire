import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/conversation_page.dart';
import 'reader_view.dart';

class ConversationListView extends StatelessWidget {
  final List<ConversationListItem> conversations;
  final VoidCallback onImportRequested;
  final Future<ConversationPage> Function({
    required int conversationId,
    required int pageIndex,
  })
  fetchPageById;
  final Future<(int?, int?)> Function({
    required int conversationId,
    required DateTime timestamp,
  })
  fetchPageAndOffset;

  const ConversationListView({
    super.key,
    required this.conversations,
    required this.onImportRequested,
    required this.fetchPageById,
    required this.fetchPageAndOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Conversations'),
        actions: [
          if (conversations.isNotEmpty)
            IconButton(
              onPressed: onImportRequested,
              icon: const Icon(Icons.file_upload),
              tooltip: 'Import WhatsApp file',
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No conversations found. Please import one.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed:
                            onImportRequested, // Notify the parent to import data
                        icon: const Icon(Icons.file_upload),
                        label: const Text(
                          'Select a file to import conversation.',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currentConversation = conversations[index];
                    return ListTile(
                      title: Text(currentConversation.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (BuildContext context) => ReaderView(
                              conversationTitle: currentConversation.title,
                              totalPages: currentConversation.totalPages,
                              fetchPage: (int pageIndex) => fetchPageById(
                                conversationId: currentConversation.id,
                                pageIndex: pageIndex,
                              ),
                              fetchPageAndOffset: (DateTime timestamp) =>
                                  fetchPageAndOffset(
                                    conversationId: currentConversation.id,
                                    timestamp: timestamp,
                                  ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
