import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_dependencies_injection.dart';
import '../mappers/message_representation_mapper.dart';
import '../models/conversation.dart';
import '../models/conversation_page.dart';
import '../repositories/conversation_repository.dart';
import '../repositories/message_repository.dart';
import '../services/import_whatsapp_service.dart';
import '../utils/path_utils.dart';
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
  final MessageRepository messageRepository = locator<MessageRepository>();
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

  Future<ConversationPage> _fetchPage({
    required int conversationId,
    required int pageIndex,
  }) async {
    final int offset = pageIndex * _pageSize;
    final messages = await messageRepository.getMessagesByConversationId(
      conversationId: conversationId,
      offset: offset,
      limit: _pageSize,
    );
    final conversationMediaPath = await getConversationMediaPath(conversationId);
    return ConversationPage(
      pageNumber: pageIndex + 1,
      messages: buildRepresentationFromDb(messages, conversationMediaPath),
    );
  }

  Future<(int?, int?)> _fetchPageAndOffset({
    required int conversationId,
    required DateTime timestamp,
  }) async {
    final offset = await messageRepository.getMessageOffsetByTimestamp(
      conversationId: conversationId,
      timestamp: timestamp,
    );
    if (offset == null) {
      return (null, null);
    } else {
      final pageIndex = offset ~/ _pageSize;
      final messageIndex = offset % _pageSize;

      return (pageIndex, messageIndex);
    }
  }

  Future<void> _pickAndImportFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.any);

      if (result == null || result.files.first.path == null) return;

      File selectedFile = File(result.files.first.path!);

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
            fetchPageById: _fetchPage,
            fetchPageAndOffset: _fetchPageAndOffset,
          );
        }

        return const Scaffold(
          body: Center(child: Text('No conversations found.')),
        );
      },
    );
  }
}
