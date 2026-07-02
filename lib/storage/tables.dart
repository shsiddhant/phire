import 'package:drift/drift.dart';

@DataClassName('MessageData')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get sender => text()();
  TextColumn get messageText => text()();
  TextColumn get attachment => text().nullable()();
  IntColumn get conversationId => integer().references(Conversations, #id)();
}

@DataClassName('ConversationData')
class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().unique()();
  TextColumn get source => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().withDefault(currentDateAndTime)();
}
