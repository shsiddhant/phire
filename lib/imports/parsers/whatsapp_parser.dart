import 'dart:io';
import '../models/parsed.dart';

ParsedLine? parseLine({required String line, required RegExp regExp}) {
  final match = regExp.firstMatch(line);

  if (match == null) {
    return null;
  } else {
    final String timestamp = match.group(1)!;
    final String sender = match.group(2)!;
    final String text = match.group(3)!;
    final bool hasAttachment = text.contains('(file attached)');

    return ParsedLine(
      timestamp: timestamp,
      sender: sender,
      text: text,
      hasAttachment: hasAttachment,
    );
  }
}

Stream<List<ParsedMessage>> parseFullExport(
  File file,
  RegExp regExp, {
  int batchSize = 5000,
}) async* {
  final lines = await file.readAsLines();

  List<ParsedMessage> messageBatch = [];
  ParsedLine? parsedLine;
  int lineNumber = 0;

  try {
    for (lineNumber; lineNumber < lines.length; lineNumber++) {
      final line = lines[lineNumber];
      if (messageBatch.length > batchSize) {
        yield messageBatch.sublist(0, messageBatch.length - 1);
        messageBatch = [messageBatch.last];
      }

      parsedLine = parseLine(line: line, regExp: regExp);
      if (parsedLine == null && lineNumber == 0) {
        throw FormatException('First line must contain all message fields');
      }
      if (parsedLine != null) {
        messageBatch.add(ParsedMessage.fromParsedLine(parsedLine));
        parsedLine = null;
      } else if (parsedLine == null && lineNumber > 0) {
        messageBatch.last.text = '${messageBatch.last.text}\n$line';
      }
    }
  } on FormatException catch (e) {
    throw FormatException('Error parsing line: $lineNumber\n${e.message}');
  } catch (e) {
    throw FormatException('Error parsing line: $lineNumber\n$e');
  }

  yield messageBatch;
}
