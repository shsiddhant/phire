import 'conversation_page.dart';
import 'message.dart';

class Conversation {
  final int id;
  final String title;
  final List<Message> messages;

  Conversation({required this.id, required this.title, required this.messages});
}

class ConversationRepresentation {
  final int id;
  final String title;
  final List<MessageRepresentation> messages;

  ConversationRepresentation({
    required this.id,
    required this.title,
    required this.messages,
  });
}

class PagedConversation {
  final int id;
  final String title;
  final List<ConversationPage> pages;

  PagedConversation({
    required this.id,
    required this.title,
    required this.pages,
  });
}

class ConversationListItem {
  final int id;
  final String title;
  final int totalPages;

  ConversationListItem({
    required this.id,
    required this.title,
    required this.totalPages,
  });
}
