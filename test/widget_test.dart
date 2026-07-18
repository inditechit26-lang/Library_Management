import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf_flutter/main.dart';

void main() {
  testWidgets('application starts on login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShelfApp()));
    await tester.pumpAndSettle();
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
