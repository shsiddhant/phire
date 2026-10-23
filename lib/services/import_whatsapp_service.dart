import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

import '../imports/parsers/whatsapp_parser.dart';
import '../repositories/import_repository.dart';
import '../utils/path_utils.dart';

class ImportWhatsappService {
  final RegExp regExp = RegExp(
    r'^(\d{2}\/\d{2}\/\d{2}, \d{2}:\d{2}) - ([^:]*): (.*)$',
  );
  final int batchSize = 5000;
  final String source = 'WhatsApp';
  final ImportRepository importRepository;

  ImportWhatsappService(this.importRepository);

  Future<int> importTextFile({
    required File file,
    required String title,
  }) async {
    final byteStream = file.openRead();
    return await _processChatLogBytes(byteStream: byteStream, title: title);
  }

  Future<({int conversationId, int failedMediaCount})> importZipFile({
    required String filePath,
    required String title,
  }) async {
    final inputStream = InputFileStream(filePath);
    final archive = ZipDecoder().decodeStream(inputStream);

    ArchiveFile? chatLogFile;
    final List<ArchiveFile> mediaFiles = [];

    for (final file in archive) {
      if (file.isFile) {
        if (file.name.startsWith('WhatsApp Chat with') &&
            file.name.endsWith('txt')) {
          chatLogFile = file;
        } else {
          mediaFiles.add(file);
        }
      }
    }

    throwIf(
      chatLogFile == null,
      FormatException("Missing 'WhatsApp Chat with... .txt' file"),
    );

    final bytes = chatLogFile!.readBytes();
    if (bytes == null) {
      throw FormatException('${chatLogFile.name} is empty or corrupted.');
    }
    final Stream<List<int>> byteStream = Stream.fromIterable([bytes]);

    final conversationId = await _processChatLogBytes(
      byteStream: byteStream,
      title: title,
    );

    final mediaPath = await getConversationMediaPath(conversationId);
    final mediaDir = Directory(mediaPath);
    await mediaDir.create(recursive: true);

    int failedMediaCount = 0;

    for (final mediaFile in mediaFiles) {
      try {
        final localFilePath = join(mediaPath, mediaFile.name);
        final outputStream = OutputFileStream(localFilePath);
        mediaFile.writeContent(outputStream);
        await outputStream.close();
      } catch (e) {
        failedMediaCount++;
      }
    }
    return (conversationId: conversationId, failedMediaCount: failedMediaCount);
  }

  Future<int> _processChatLogBytes({
    required Stream<List<int>> byteStream,
    required String title,
  }) async {
    final lineStream = byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final batches = parseFullExport(lineStream, regExp, batchSize: batchSize);

    final int conversationId = await importRepository.importConversation(
      title: title,
      source: source,
      batches: batches,
    );

    return conversationId;
  }
}
