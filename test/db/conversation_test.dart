/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phire/exceptions/conversation_already_exists.dart';
import 'package:phire/repositories/conversation_repository.dart';
import 'package:phire/storage/database.dart';

void main() {
  late AppDatabase db;
  late ConversationRepository repository;
  late ConversationData firstConversation;
  late ConversationData secondConversation;

  setUp(() async {
    db = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
    repository = ConversationRepository(db);

    final firstId = await db
        .into(db.conversations)
        .insert(ConversationsCompanion.insert(title: 'TheGreenButterfly'));

    final secondId = await db
        .into(db.conversations)
        .insert(ConversationsCompanion.insert(title: 'Allons-y'));

    firstConversation = await (db.select(
      db.conversations,
    )..where((tbl) => tbl.id.equals(firstId))).getSingle();

    secondConversation = await (db.select(
      db.conversations,
    )..where((tbl) => tbl.id.equals(secondId))).getSingle();
  });

  tearDown(() async {
    await db.close();
  });

  test('Should rename conversation successfully', () async {
    final newTitle = "Carissa's Wierd";

    final result = await repository.renameConversation(
      id: 1,
      newTitle: newTitle,
    );

    expect(result, 1);

    final updated = await (db.select(
      db.conversations,
    )..where((tbl) => tbl.id.equals(1))).getSingle();

    expect(updated.title, newTitle);
  });

  test(
    'Should throw ConversationAlreadyExistsException when title already exists',
    () async {
      expect(
        () => repository.renameConversation(
          id: firstConversation.id,
          newTitle: secondConversation.title,
        ),
        throwsA(isA<ConversationAlreadyExistsException>()),
      );
    },
  );
}
