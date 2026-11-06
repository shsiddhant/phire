/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phire/models/search.dart';
import 'package:phire/repositories/sqlite_search_repository.dart';
import 'package:phire/storage/database.dart';

void main() {
  late AppDatabase db;
  late SqliteSearchRepository repository;

  setUp(() async {
    db = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
    repository = SqliteSearchRepository(db);

    await db.batch((batch) {
      batch.insertAll(db.conversations, [
        ConversationsCompanion.insert(
          id: const Value(1),
          title: 'TheGreenButterfly',
        ),
        ConversationsCompanion.insert(
          id: const Value(2),
          title: 'The Best Day',
        ),
      ]);

      batch.insertAll(db.messages, [
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2024-04-06T13:28:00+05:30'),
          messageText: "Booked a doctor's appointment",
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2024-04-06T13:28:00+05:30'),
          messageText: 'At 3pm',
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheMonster',
          timestamp: DateTime.parse('2024-04-06T13:39:00+05:30'),
          messageText:
              "Oh, I hope the problem didn't get worse? In any case it's good you are seeing a doctor",
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheMonster',
          timestamp: DateTime.parse('2024-04-06T13:40:00+05:30'),
          messageText: 'Going alone? Or is someone else going with you?',
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2024-04-06T13:41:00+05:30'),
          messageText: 'Alone',
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2024-04-06T13:41:00+05:30'),
          messageText: "No it's okay rn",
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2024-04-06T13:41:00+05:30'),
          messageText: 'I mean same as yesterday',
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheMonster',
          timestamp: DateTime.parse('2024-04-06T13:43:00+05:30'),
          messageText: 'Okay. I can come with you if you want',
        ),
        MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2024-04-06T13:43:00+05:30'),
          messageText: 'Oke 🥹',
        ),
        MessagesCompanion.insert(
          conversationId: 2,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2023-12-16T19:13:00+05:30'),
          messageText: 'Excited for tomorrow??',
        ),
        MessagesCompanion.insert(
          conversationId: 2,
          sender: 'TheMonster',
          timestamp: DateTime.parse('2023-12-16T19:15:00+05:30'),
          messageText: '200% !!!',
        ),
        MessagesCompanion.insert(
          conversationId: 2,
          sender: 'TheGreenButterfly',
          timestamp: DateTime.parse('2023-12-17T16:45:00+05:30'),
          messageText: "I've booked an auto. Should be here in 10",
        ),
      ]);
    });
  });

  tearDown(() async {
    await db.close();
  });

  group('SqliteSearchRepository Tests', () {
    test('Should return matches within the specific conversation', () async {
      final results = await repository.search(
        conversationId: 2,
        query: 'booked',
      );

      expect(results.length, 1);
      expect(results.first.sender, 'TheGreenButterfly');
      expect(results.first.messageText, contains('booked'));
      expect(results.first.messageText, contains('auto'));
    });

    test('Should handle empty or whitespace-only queries safely', () async {
      final results = await repository.search(conversationId: 1, query: '   ');

      expect(results, isEmpty);
    });

    test('Should respect limit and offset', () async {
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              conversationId: 1,
              sender: 'TheGreenButterfly',
              timestamp: DateTime.parse('2024-04-06 14:27:00+05:30'),
              messageText: 'Can you book an auto',
            ),
          );

      final pageOne = await repository.search(
        conversationId: 1,
        query: 'book',
        limit: 1,
        offset: 0,
      );
      expect(pageOne.length, 1);

      final pageTwo = await repository.search(
        conversationId: 1,
        query: 'book',
        limit: 1,
        offset: 1,
      );
      expect(pageTwo.length, 1);
      expect(pageOne.first.messageId, isNot(pageTwo.first.messageId));
    });

    test('Should find message with apostrophe', () async {
      final results = await repository.search(
        conversationId: 1,
        query: "doctor's",
      );

      expect(results.length, 1);
      expect(results.first.sender, 'TheGreenButterfly');
      expect(results.first.messageText, contains("doctor's appointment"));
    });

    test('Should handle message containing emojis', () async {
      final results = await repository.search(conversationId: 1, query: '🥹');

      expect(results.length, 1);
      expect(results.first.messageText, 'Oke 🥹');
    });

    test('Should escape percentage wildcard character', () async {
      final results = await repository.search(conversationId: 2, query: '200%');

      expect(results.length, 1);
      expect(results.first.messageText, contains('200% !'));
    });

    test('Should return matches sorted oldest first', () async {
      final results = await repository.search(
        conversationId: 1,
        query: 'doctor',
      );

      expect(results.length, 2);
      expect(
        results.first.messageText,
        contains("Booked a doctor's appointment"),
      );
      expect(results.last.messageText, contains('seeing a doctor'));
      expect(results.first.messageId, lessThan(results.last.messageId));
    });

    test('Should return matches sorted newest first', () async {
      final results = await repository.search(
        conversationId: 1,
        query: 'doctor',
        sortOrder: SearchSort.newestFirst,
      );

      expect(results.length, 2);
      expect(results.first.messageText, contains('seeing a doctor'));
      expect(
        results.last.messageText,
        contains("Booked a doctor's appointment"),
      );
      expect(results.first.messageId, greaterThan(results.last.messageId));
    });

    test('Should break timestamp ties using id', () async {
      final results = await repository.search(conversationId: 1, query: 'Ok');
      final collidingMatches = results
          .where(
            (m) =>
                m.messageText.contains('I can come with you') ||
                m.messageText.contains('Oke'),
          )
          .toList();

      expect(collidingMatches.length, 2);
      expect(
        collidingMatches.first.timestamp == collidingMatches.last.timestamp,
        isTrue,
      );
      expect(
        collidingMatches.first.messageText,
        contains('I can come with you'),
      );
      expect(collidingMatches.last.messageText, contains('Oke'));
    });
  });
}
