import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf_flutter/features/settings/providers/settings_provider.dart';
import 'package:shelf_flutter/features/settings/screens/library_configuration_screen.dart';
import 'package:shelf_flutter/features/settings/models/library_configuration.dart';
import 'package:shelf_flutter/features/settings/models/pricing_settings.dart';

void main() {
  test('seat labels follow the saved numbering configuration', () {
    final numeric = LibraryConfiguration.defaults.copyWith(
      seatNumbering: const SeatNumberingConfiguration(
        style: SeatNumberingStyle.numeric,
        startingNumber: 10,
      ),
    );
    final alphabetic = LibraryConfiguration.defaults.copyWith(
      seatNumbering: const SeatNumberingConfiguration(
        style: SeatNumberingStyle.alphabetic,
        prefix: 'B',
        endingPrefix: 'C',
        startingNumber: 4,
        numbersPerPrefix: 2,
      ),
    );

    expect(numeric.nextSeatLabel(['10', '11']), '12');
    expect(alphabetic.nextSeatLabel(['B4', 'B5']), 'C4');
    expect(
      LibraryConfiguration.defaults.priceFor(
        MembershipPeriod.monthly,
        sectionId: 'ac',
      ),
      0,
    );
  });

  test('membership plans and prices are stored per section', () {
    final configuration = LibraryConfiguration.fromMap({
      'membershipPlans': ['monthly', 'quarterly'],
      'membershipPlanPrices': {'monthly': 1000, 'quarterly': 2700},
      'sections': [
        {'id': 'ac', 'name': 'AC', 'color': 0xFF4F6BED, 'additionalPrice': 300},
        {
          'id': 'silent',
          'name': 'Silent',
          'color': 0xFF267A5E,
          'membershipPlans': ['monthly'],
          'membershipPlanPrices': {'monthly': 1500},
        },
      ],
    });

    expect(
      configuration.membershipPeriodsForSection('ac'),
      containsAll([MembershipPeriod.monthly, MembershipPeriod.quarterly]),
    );
    expect(
      configuration.priceFor(MembershipPeriod.monthly, sectionId: 'ac'),
      1300,
    );
    expect(
      configuration.priceFor(MembershipPeriod.monthly, sectionId: 'silent'),
      1500,
    );
    expect(configuration.toMap().containsKey('membershipPlanPrices'), isFalse);
  });

  Widget app() => ProviderScope(
    overrides: [
      libraryConfigProvider.overrideWith(
        (ref) => Stream.value(const <String, dynamic>{}),
      ),
    ],
    child: const MaterialApp(home: LibraryConfigurationScreen()),
  );

  testWidgets('renders all operation categories without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Library Configuration'), findsOneWidget);
    expect(find.text('Sections'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Seat Types'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Seat Types'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Seat Numbering Style'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Seat Numbering Style'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
