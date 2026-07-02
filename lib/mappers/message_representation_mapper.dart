import 'package:intl/intl.dart';
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
  }) {
    final formattedTime = timeFormat.format(timestamp);
    final DateTime localTimestamp = timestamp.toLocal();
    final dayMarker = isFirstOfDay ? dateFormat.format(localTimestamp) : null;
    return MessageRepresentation(
      formattedTime: formattedTime,
      senderName: sender,
      messageText: messageText,
      showSenderHeader: showSenderHeader,
      isFirstOfDay: isFirstOfDay,
      dayMarker: dayMarker,
    );
  }
}

List<MessageRepresentation> buildRepresentationFromDb(
  List<MessageData> messages,
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
      ),
    );
  }

  return messagesRepr;
}
