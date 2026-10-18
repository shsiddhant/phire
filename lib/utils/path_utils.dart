import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> getConversationMediaPath(int conversationId) async {
  final Directory baseDir =
      (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
      ? await getApplicationSupportDirectory()
      : await getApplicationDocumentsDirectory();

  return p.join(baseDir.path, 'media', conversationId.toString());
}
