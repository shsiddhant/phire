/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phire/widgets/confirm_dialog.dart';

void main() {
  group('showConfirmDialog Widget Tests', () {
    testWidgets('successfully completes onConfirm and dismisses dialog', (
      WidgetTester tester,
    ) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showConfirmDialog(
                    context: context,
                    title: 'Delete Item',
                    message: 'Are you sure you want to delete this?',
                    onConfirm: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      actionCalled = true;
                    },
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete Item'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Yes'));

      // Let the async task and route pop finish settling
      await tester.pumpAndSettle();

      expect(actionCalled, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'handles errors gracefully, shows loading, and keeps dialog open',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await showConfirmDialog(
                      context: context,
                      title: 'Sync Data',
                      message: 'Start sync?',
                      onConfirm: () async {
                        await Future.delayed(const Duration(milliseconds: 50));
                        throw Exception('Network timeout');
                      },
                      errorMessageBuilder: (error) => 'Sync failed: $error',
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Yes'));

        await tester.pump();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(
          find.text('Sync failed: Exception: Network timeout'),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  });
}
