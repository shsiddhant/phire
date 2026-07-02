import 'dart:io';
import '../imports/parsers/whatsapp_parser.dart';
import '../repositories/import_repository.dart';

class ImportWhatsappService {
  final RegExp regExp = RegExp(
    r'^(\d{2}\/\d{2}\/\d{2}, \d{2}:\d{2}) - ([^:]*): (.*)$',
  );
  final int batchSize = 5000;
  final String source = 'WhatsApp';
  final ImportRepository importRepository;

  ImportWhatsappService(this.importRepository);

  Future<int> importFile({required File file, required String title}) async {
    final batches = parseFullExport(file, regExp, batchSize: batchSize);
    final int conversationId = await importRepository.importConversation(
      title: title,
      source: source,
      batches: batches,
    );
    return conversationId;
  }
}
