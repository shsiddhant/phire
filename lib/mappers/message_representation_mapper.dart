import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../utils/date_utils.dart';
import '../models/message.dart';
import '../storage/database.dart';

final dateFormat = DateFormat('EEEE, MMM d, yyyy');
final timeFormat = DateFormat.jm();

extension MessageDataToRepresentation on MessageData {
  MessageRepresentation toRepresentation({
    required bool showSenderHeader,
    required bool isFirstOfDay,
    required DateFormat dateFormat,
    required DateFormat timeFormat,
    required String conversationMediaPath,
  }) {
    final formattedTime = timeFormat.format(timestamp);
    final DateTime localTimestamp = timestamp.toLocal();
    final dayMarker = isFirstOfDay ? dateFormat.format(localTimestamp) : null;

    bool hasAttachment = attachment != null && attachment!.isNotEmpty;
    final attachmentFilePath = hasAttachment
        ? p.join(conversationMediaPath, attachment)
        : null;
    final renderAttachment =
        hasAttachment &&
        attachment!.startsWith('STK') &&
        attachment!.endsWith('.webp');

    final messageTextRepr = hasAttachment
        ? messageText.replaceAll('$attachment (file attached)', '').trimLeft()
        : messageText;

    return MessageRepresentation(
      formattedTime: formattedTime,
      senderName: sender,
      messageText: messageTextRepr,
      attachmentFilePath: attachmentFilePath,
      renderAttachment: renderAttachment,
      showSenderHeader: showSenderHeader,
      isFirstOfDay: isFirstOfDay,
      dayMarker: dayMarker,
    );
  }
}

List<MessageRepresentation> buildRepresentationFromDb(
  List<MessageData> messages,
  String conversationMediaPath,
) {
  List<MessageRepresentation> messagesRepr = [];

  if (messages.isEmpty) {
    return messagesRepr;
  }

  messagesRepr.add(
    messages[0].toRepresentation(
      showSenderHeader: true,
      isFirstOfDay: true,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      conversationMediaPath: conversationMediaPath,
    ),
  );

  for (int i = 1; i < messages.length; i++) {
    final isFirstOfDay = isDifferentDay(
      messages[i].timestamp.toLocal(),
      messages[i - 1].timestamp.toLocal(),
    );
    messagesRepr.add(
      messages[i].toRepresentation(
        showSenderHeader: messages[i].sender != messages[i - 1].sender,
        isFirstOfDay: isFirstOfDay,
        dateFormat: dateFormat,
        timeFormat: timeFormat,
        conversationMediaPath: conversationMediaPath,
      ),
    );
  }

  return messagesRepr;
}
