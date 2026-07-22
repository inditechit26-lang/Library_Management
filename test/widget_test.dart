import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:shelf_flutter/core/theme/app_theme.dart';
import 'package:shelf_flutter/features/seats/screens/seat_settings_screen.dart';

void main() {
  testWidgets('application starts on login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShelfApp()));
    await tester.pumpAndSettle();
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });

  testWidgets('seat label dialog closes without disposed controller errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SeatSettingsScreen(),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Add seat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'VIP-01');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Add new seat'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
