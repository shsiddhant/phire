/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:phire/storage/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldConversationsData = <v1.ConversationsData>[];
    final expectedNewConversationsData = <v2.ConversationsData>[];

    final oldMessagesData = <v1.MessagesData>[];
    final expectedNewMessagesData = <v2.MessagesData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.conversations, oldConversationsData);
        batch.insertAll(oldDb.messages, oldMessagesData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewConversationsData,
          await newDb.select(newDb.conversations).get(),
        );
        expect(
          expectedNewMessagesData,
          await newDb.select(newDb.messages).get(),
        );
      },
    );
  });

  test('v2 to v3 cascades delete', () async {
    final schema = await verifier.schemaAt(2);
    final oldDb = v2.DatabaseAtV2(schema.newConnection());

    await oldDb.batch((batch) {
      batch.insertAll(oldDb.conversations, [
        v2.ConversationsCompanion.insert(
          id: const Value(1),
          title: 'TheGreenButterfly',
        ),
        v2.ConversationsCompanion.insert(
          id: const Value(2),
          title: 'The Best Day',
        ),
      ]);

      batch.insertAll(oldDb.messages, [
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: '2024-04-06T13:28:00+05:30',
          messageText: "Booked a doctor's appointment",
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: '2024-04-06T13:28:00+05:30',
          messageText: 'At 3pm',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheMonster',
          timestamp: '2024-04-06T13:39:00+05:30',
          messageText:
              "Oh, I hope the problem didn't get worse? In any case it's good you are seeing a doctor",
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheMonster',
          timestamp: '2024-04-06T13:40:00+05:30',
          messageText: 'Going alone? Or is someone else going with you?',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: '2024-04-06T13:41:00+05:30',
          messageText: 'Alone',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: '2024-04-06T13:41:00+05:30',
          messageText: "No it's okay rn",
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: '2024-04-06T13:41:00+05:30',
          messageText: 'I mean same as yesterday',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheMonster',
          timestamp: '2024-04-06T13:43:00+05:30',
          messageText: 'Okay. I can come with you if you want',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 1,
          sender: 'TheGreenButterfly',
          timestamp: '2024-04-06T13:43:00+05:30',
          messageText: 'Oke 🥹',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 2,
          sender: 'TheGreenButterfly',
          timestamp: '2023-12-16T19:13:00+05:30',
          messageText: 'Excited for tomorrow??',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 2,
          sender: 'TheMonster',
          timestamp: '2023-12-16T19:15:00+05:30',
          messageText: '200% !!!',
        ),
        v2.MessagesCompanion.insert(
          conversationId: 2,
          sender: 'TheGreenButterfly',
          timestamp: '2023-12-17T16:45:00+05:30',
          messageText: "I've booked an auto. Should be here in 10",
        ),
      ]);

      batch.insert(
        oldDb.readingProgress,
        v2.ReadingProgressCompanion.insert(
          conversationId: Value(1),
          messageId: 5,
        ),
      );
    });
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    await db.close();

    final migratedDb = v3.DatabaseAtV3(schema.newConnection());
    await migratedDb.customStatement('PRAGMA foreign_keys = ON');

    expect(await migratedDb.messages.count().getSingle(), 12);
    expect(await migratedDb.readingProgress.count().getSingle(), 1);

    await (migratedDb.delete(
      migratedDb.conversations,
    )..where((tbl) => tbl.id.equals(1))).go();

    expect(await migratedDb.messages.count().getSingle(), 3);
    expect(await migratedDb.readingProgress.count().getSingle(), 0);

    final conv1Messages = await migratedDb.messages
        .count(where: (m) => m.conversationId.equals(1))
        .getSingle();
    expect(conv1Messages, 0);

    await migratedDb.close();
  });
}
