/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../models/conversation.dart';
import '../widgets/action_menu.dart';
import 'about_page.dart';
import 'reader_view.dart';

class ConversationListView extends StatelessWidget {
  final List<ConversationListItem> conversations;
  final VoidCallback onImportRequested;
  final Future<void> Function(int conversationId) onDeleteRequested;
  final Future<void> Function(ConversationListItem conversation)
  onRenameRequested;

  const ConversationListView({
    super.key,
    required this.conversations,
    required this.onImportRequested,
    required this.onDeleteRequested,
    required this.onRenameRequested,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text('Conversations'),
        actions: [
          ActionMenuButton(
            actions: [
              ActionMenuItem(
                label: 'About',
                icon: Icons.info,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => AboutPage()),
                ),
              ),
            ],
          ),
        ],
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
                  trailing: ActionMenuButton(
                    position: .under,
                    actions: [
                      ActionMenuItem(
                        label: 'Rename',
                        icon: Icons.edit_outlined,
                        onTap: () => onRenameRequested(currentConversation),
                      ),
                      ActionMenuItem(
                        label: 'Delete',
                        icon: Icons.delete_outline,
                        onTap: () => onDeleteRequested(currentConversation.id),
                      ),
                    ],
                  ),
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
