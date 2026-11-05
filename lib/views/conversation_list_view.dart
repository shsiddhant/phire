/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        ),
      ),
    );
  }
}
