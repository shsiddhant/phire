/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phire/app_dependencies_injection.dart';

import 'package:phire/main.dart';
import 'package:phire/repositories/conversation_repository.dart';
import 'package:phire/services/import_whatsapp_service.dart';

class MockConversationRepository extends Mock
    implements ConversationRepository {}

class MockImportService extends Mock implements ImportWhatsappService {}

void main() {
  late MockConversationRepository mockConversationRepository;
  late ImportWhatsappService importWhatsappService;

  setUp(() {
    mockConversationRepository = MockConversationRepository();
    importWhatsappService = MockImportService();

    locator.registerSingleton<ConversationRepository>(
      mockConversationRepository,
    );
    locator.registerSingleton<ImportWhatsappService>(importWhatsappService);
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
