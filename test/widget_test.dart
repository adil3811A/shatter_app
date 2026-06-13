import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shatter_app/my_app.dart';
import 'package:shatter_app/utils/env.dart' as env;

void main() {
  env.isTesting = true;

  testWidgets('Bottom navigation bar navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial tab is Chats (header and bottom navigation label) and displays contacts.
    expect(find.text('Chats'), findsNWidgets(2));
    expect(find.text('Alex Mercer'), findsOneWidget);

    // Find the Settings icon in the navigation bar
    final settingsIconFinder = find.byIcon(Icons.settings_outlined);
    expect(settingsIconFinder, findsOneWidget);

    // Tap on the Settings icon to switch screens
    await tester.tap(settingsIconFinder);
    await tester.pumpAndSettle();

    // Verify that the page transitioned to the Settings screen with Julian Vane profile details
    expect(find.text('Settings'), findsNWidgets(2));
    expect(find.text('Julian Vane'), findsOneWidget);
    expect(find.text('E2E Encryption'), findsOneWidget);
  });
}
