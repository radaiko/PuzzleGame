// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:puzzle_game/main.dart';
import 'package:puzzle_game/services/service_locator.dart';

void main() {
  testWidgets('App starts and shows level text', (WidgetTester tester) async {
    // Initialize services before building the app
    await initializeServices();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the async operations to complete
    await tester.pumpAndSettle();

    // Verify that our app shows the level text
    expect(find.textContaining('Level'), findsOneWidget);

    // Verify that we have a Start button
    expect(find.text('Start'), findsOneWidget);
  });
}
