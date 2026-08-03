import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter/features/settings/screens/libraries_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: LibrariesScreen(),
      ),
    );
  }

  testWidgets('LibrariesScreen renders title, subtitle, cards and bottom button', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Libraries'), findsNWidgets(2)); // AppBar title + Header title
    expect(find.text('Manage and switch between your library branches.'), findsOneWidget);
    expect(find.text('Bright Minds Library'), findsOneWidget);
    expect(find.text('Central Study Library'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Add New Library'), findsOneWidget);
  });

  testWidgets('Tapping a library card updates active selection visually with overlay', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap on second library card
    await tester.tap(find.text('Central Study Library'));
    await tester.pump();

    // Verify overlay appears during transition
    expect(find.text('SWITCHING LIBRARY'), findsOneWidget);

    // Complete timer and reverse animation
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('Tapping Add New Library opens bottom sheet', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add New Library'));
    await tester.pumpAndSettle();

    expect(find.text('Create New Library'), findsOneWidget);
    expect(find.text('Create Library'), findsOneWidget);
    expect(find.text('Library Name'), findsOneWidget);
    expect(find.text('Library Logo'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel to dismiss sheet
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Library Logo'), findsNothing);
  });
}
