/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../app_dependencies_injection.dart';
import '../models/conversation.dart';
import '../repositories/conversation_repository.dart';
import '../services/import_whatsapp_service.dart';
import '../widgets/conversation_title_dialog.dart';
import 'conversation_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _pageSize = 30;
  final ConversationRepository conversationRepository =
      locator<ConversationRepository>();
  final ImportWhatsappService _importWhatsappService =
      locator<ImportWhatsappService>();
  late Future<List<ConversationListItem>> _processedConversations;

  @override
  void initState() {
    super.initState();
    _processedConversations = _loadConversations();
  }

  Future<List<ConversationListItem>> _loadConversations() async {
    final conversations = await conversationRepository.getConversationList(
      _pageSize,
    );

    return conversations;
  }

  Future<void> _pickAndImportFile() async {
    try {
      List<PlatformFile> files = await FilePicker.pickFiles(type: FileType.any);

      if (files.isEmpty || files.first.path == null) return;

      File selectedFile = File(files.first.path!);

      final defaultTitle = p.basenameWithoutExtension(selectedFile.path);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (BuildContext context) => ConversationTitleDialog(
          title: 'Import WhatsApp File',
          defaultConversationTitle: defaultTitle,
          actionName: 'Import',
          onSubmit: (title) async {
            final filePath = selectedFile.path;
            final extension = p.extension(filePath);

            int failedMediaCount = 0;

            if (extension == '.zip') {
              final result = await _importWhatsappService.importZipFile(
                filePath: filePath,
                title: title,
              );
              failedMediaCount = result.failedMediaCount;
            } else if (extension == '.txt') {
              await _importWhatsappService.importTextFile(
                file: selectedFile,
                title: title,
              );
            } else {
              throw const FormatException('Please select a .txt or .zip file.');
            }

            if (!context.mounted) return;

            setState(() {
              _processedConversations = _loadConversations();
            });

            if (failedMediaCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Chat imported! $failedMediaCount media files failed to copy.',
                  ),
                ),
              );
            }
          },
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to import file: $error')),
              );
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to import file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _processedConversations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading data: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          return ConversationListView(
            conversations: snapshot.data!,
            onImportRequested: _pickAndImportFile,
          );
        }

        return const Scaffold(
          body: Center(child: Text('No conversations found.')),
        );
      },
    );
  }
}
