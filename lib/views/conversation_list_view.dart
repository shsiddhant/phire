/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../models/conversation.dart';
import 'reader_view.dart';

class ConversationListView extends StatelessWidget {
  final List<ConversationListItem> conversations;
  final VoidCallback onImportRequested;

  const ConversationListView({
    super.key,
    required this.conversations,
    required this.onImportRequested,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text('Conversations'),
      ),
      body: conversations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 56,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No conversations yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to import a conversation.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                        builder: (BuildContext context) {
                          return ReaderView(
                            conversationId: currentConversation.id,
                            conversationTitle: currentConversation.title,
                            totalPages: currentConversation.totalPages,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onImportRequested,
        backgroundColor: colorScheme.inversePrimary,
        foregroundColor: colorScheme.onPrimaryContainer,
        tooltip: 'Import a conversation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
