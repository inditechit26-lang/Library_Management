import 'package:flutter/material.dart';
import 'pricing_settings.dart';

enum LibrarySeatType { fullTimeReserved, halfTimeOpenSeating, halfTimeReserved }

enum SeatNumberingStyle { numeric, alphabetic }

enum StudentDocumentRequirement {
  studentPhoto,
  aadhaarCard,
  addressProof,
  parentId,
  collegeId,
}

@immutable
class LibrarySection {
  const LibrarySection({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isEnabled = true,
    this.membershipPeriods = const {MembershipPeriod.monthly},
    this.planPrices = const {
      MembershipPeriod.monthly: 0,
      MembershipPeriod.quarterly: 0,
      MembershipPeriod.halfYearly: 0,
      MembershipPeriod.annual: 0,
      MembershipPeriod.custom: 0,
    },
    this.fullTimePlanPrices,
    this.halfTimePlanPrices,
  });

  final String id;
  final String name;
  final int colorValue;
  final bool isEnabled;
  final Set<MembershipPeriod> membershipPeriods;
  final Map<MembershipPeriod, double> planPrices;
  final Map<MembershipPeriod, double>? fullTimePlanPrices;
  final Map<MembershipPeriod, double>? halfTimePlanPrices;

  Color get color => Color(colorValue);

  LibrarySection copyWith({
    String? name,
    int? colorValue,
    bool? isEnabled,
    Set<MembershipPeriod>? membershipPeriods,
    Map<MembershipPeriod, double>? planPrices,
    Map<MembershipPeriod, double>? fullTimePlanPrices,
    Map<MembershipPeriod, double>? halfTimePlanPrices,
  }) => LibrarySection(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    isEnabled: isEnabled ?? this.isEnabled,
    membershipPeriods: membershipPeriods ?? this.membershipPeriods,
    planPrices: planPrices ?? this.planPrices,
    fullTimePlanPrices: fullTimePlanPrices ?? this.fullTimePlanPrices,
    halfTimePlanPrices: halfTimePlanPrices ?? this.halfTimePlanPrices,
  );

  Map<MembershipPeriod, double> pricesFor({required bool isFullTime}) =>
      isFullTime
      ? fullTimePlanPrices ?? planPrices
      : halfTimePlanPrices ?? planPrices;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': colorValue,
    'isEnabled': isEnabled,
    'membershipPlans': membershipPeriods.map((item) => item.name).toList(),
    'membershipPlanPrices': {
      for (final entry in planPrices.entries) entry.key.name: entry.value,
    },
    'fullTimePlanPrices': {
      for (final entry in pricesFor(isFullTime: true).entries)
        entry.key.name: entry.value,
    },
    'halfTimePlanPrices': {
      for (final entry in pricesFor(isFullTime: false).entries)
        entry.key.name: entry.value,
    },
  };

  factory LibrarySection.fromMap(
    Map<String, dynamic> value, {
    Set<MembershipPeriod>? legacyPeriods,
    Map<MembershipPeriod, double>? legacyPrices,
  }) {
    MembershipPeriod? parsePeriod(Object? name) {
      for (final period in MembershipPeriod.values) {
        if (period.name == name) return period;
      }
      return null;
    }

    final periods = (value['membershipPlans'] as List<dynamic>?)
        ?.map(parsePeriod)
        .whereType<MembershipPeriod>()
        .toSet();
    final legacyAdditional =
        (value['additionalPrice'] as num?)?.toDouble() ?? 0;
    Map<MembershipPeriod, double> parsePrices(Object? raw) {
      final values = raw is Map
          ? Map<String, dynamic>.from(raw)
          : const <String, dynamic>{};
      return {
        for (final period in MembershipPeriod.values)
          period:
              (values[period.name] as num?)?.toDouble() ??
              ((legacyPrices?[period] ?? 0) + legacyAdditional),
      };
    }

    final legacyPlanPrices = parsePrices(value['membershipPlanPrices']);
    return LibrarySection(
      id: value['id'] as String? ?? '',
      name: value['name'] as String? ?? '',
      colorValue:
          (value['color'] as num?)?.toInt() ??
          const Color(0xFF625CDB).toARGB32(),
      isEnabled: value['isEnabled'] as bool? ?? true,
      membershipPeriods:
          periods ?? legacyPeriods ?? const {MembershipPeriod.monthly},
      planPrices: legacyPlanPrices,
      fullTimePlanPrices: value['fullTimePlanPrices'] is Map
          ? parsePrices(value['fullTimePlanPrices'])
          : legacyPlanPrices,
      halfTimePlanPrices: value['halfTimePlanPrices'] is Map
          ? parsePrices(value['halfTimePlanPrices'])
          : legacyPlanPrices,
    );
  }
}

@immutable
class SeatNumberingConfiguration {
  const SeatNumberingConfiguration({
    this.style = SeatNumberingStyle.numeric,
    this.startingNumber = 1,
    this.endingNumber = 100,
    this.prefix = 'A',
    this.endingPrefix = 'A',
    this.numbersPerPrefix = 10,
  });

  final SeatNumberingStyle style;
  final int startingNumber;
  final int endingNumber;
  final String prefix;
  final String endingPrefix;
  final int numbersPerPrefix;

  SeatNumberingConfiguration copyWith({
    SeatNumberingStyle? style,
    int? startingNumber,
    int? endingNumber,
    String? prefix,
    String? endingPrefix,
    int? numbersPerPrefix,
  }) => SeatNumberingConfiguration(
    style: style ?? this.style,
    startingNumber: startingNumber ?? this.startingNumber,
    endingNumber: endingNumber ?? this.endingNumber,
    prefix: prefix ?? this.prefix,
    endingPrefix: endingPrefix ?? this.endingPrefix,
    numbersPerPrefix: numbersPerPrefix ?? this.numbersPerPrefix,
  );

  Map<String, dynamic> toMap() => {
    'style': style.name,
    'startingNumber': startingNumber,
    'endingNumber': endingNumber,
    'prefix': prefix,
    'endingPrefix': endingPrefix,
    'numbersPerPrefix': numbersPerPrefix,
  };
}

@immutable
class ShiftTimingConfiguration {
  const ShiftTimingConfiguration({
    this.fullTimeStart = '06:00',
    this.fullTimeEnd = '22:00',
    this.halfTimeStart = '06:00',
    this.halfTimeEnd = '14:00',
  });

  final String fullTimeStart;
  final String fullTimeEnd;
  final String halfTimeStart;
  final String halfTimeEnd;

  ShiftTimingConfiguration copyWith({
    String? fullTimeStart,
    String? fullTimeEnd,
    String? halfTimeStart,
    String? halfTimeEnd,
  }) => ShiftTimingConfiguration(
    fullTimeStart: fullTimeStart ?? this.fullTimeStart,
    fullTimeEnd: fullTimeEnd ?? this.fullTimeEnd,
    halfTimeStart: halfTimeStart ?? this.halfTimeStart,
    halfTimeEnd: halfTimeEnd ?? this.halfTimeEnd,
  );

  Map<String, dynamic> toMap() => {
    'fullTime': {'start': fullTimeStart, 'end': fullTimeEnd},
    'halfTime': {'start': halfTimeStart, 'end': halfTimeEnd},
  };

  factory ShiftTimingConfiguration.fromMap(Map<String, dynamic> value) {
    final fullTime = value['fullTime'] is Map
        ? Map<String, dynamic>.from(value['fullTime'] as Map)
        : const <String, dynamic>{};
    final halfTime = value['halfTime'] is Map
        ? Map<String, dynamic>.from(value['halfTime'] as Map)
        : const <String, dynamic>{};
    return ShiftTimingConfiguration(
      fullTimeStart: fullTime['start'] as String? ?? '06:00',
      fullTimeEnd: fullTime['end'] as String? ?? '22:00',
      halfTimeStart: halfTime['start'] as String? ?? '06:00',
      halfTimeEnd: halfTime['end'] as String? ?? '14:00',
    );
  }
}

@immutable
class LibraryConfiguration {
  const LibraryConfiguration({
    required this.membershipPeriods,
    required this.planPrices,
    required this.seatTypes,
    required this.sections,
    required this.requiredDocuments,
    required this.seatNumbering,
    required this.shiftTimings,
  });

  final Set<MembershipPeriod> membershipPeriods;
  final Map<MembershipPeriod, double> planPrices;
  final Set<LibrarySeatType> seatTypes;
  final List<LibrarySection> sections;
  final Set<StudentDocumentRequirement> requiredDocuments;
  final SeatNumberingConfiguration seatNumbering;
  final ShiftTimingConfiguration shiftTimings;

  static const defaults = LibraryConfiguration(
    membershipPeriods: {MembershipPeriod.monthly},
    planPrices: {
      MembershipPeriod.monthly: 0,
      MembershipPeriod.quarterly: 0,
      MembershipPeriod.halfYearly: 0,
      MembershipPeriod.annual: 0,
      MembershipPeriod.custom: 0,
    },
    seatTypes: {LibrarySeatType.fullTimeReserved},
    sections: [
      LibrarySection(id: 'ac', name: 'AC Section', colorValue: 0xFF4F6BED),
      LibrarySection(
        id: 'non_ac',
        name: 'Non-AC Section',
        colorValue: 0xFF5F6B7A,
      ),
    ],
    requiredDocuments: {},
    seatNumbering: SeatNumberingConfiguration(),
    shiftTimings: ShiftTimingConfiguration(),
  );

  bool get fullTimeEnabled =>
      seatTypes.contains(LibrarySeatType.fullTimeReserved);
  bool get halfTimeEnabled =>
      seatTypes.contains(LibrarySeatType.halfTimeOpenSeating) ||
      seatTypes.contains(LibrarySeatType.halfTimeReserved);
  List<LibrarySection> get enabledSections =>
      sections.where((section) => section.isEnabled).toList(growable: false);

  LibrarySection? sectionById(String? sectionId) {
    for (final section in sections) {
      if (section.id == sectionId) return section;
    }
    return null;
  }

  Set<MembershipPeriod> membershipPeriodsForSection(String? sectionId) =>
      sectionById(sectionId)?.membershipPeriods ??
      (enabledSections.isEmpty
          ? const {MembershipPeriod.monthly}
          : enabledSections.first.membershipPeriods);

  double priceFor(
    MembershipPeriod period, {
    String? sectionId,
    bool isFullTime = true,
  }) {
    final section = sectionById(sectionId);
    return section?.pricesFor(isFullTime: isFullTime)[period] ??
        (enabledSections.isEmpty
            ? 0
            : enabledSections.first.pricesFor(isFullTime: isFullTime)[period] ??
                  0);
  }

  PlanPricing pricingForSection(String? sectionId, {bool isFullTime = true}) =>
      PlanPricing(
        monthly: priceFor(
          MembershipPeriod.monthly,
          sectionId: sectionId,
          isFullTime: isFullTime,
        ),
        quarterly: priceFor(
          MembershipPeriod.quarterly,
          sectionId: sectionId,
          isFullTime: isFullTime,
        ),
        halfYearly: priceFor(
          MembershipPeriod.halfYearly,
          sectionId: sectionId,
          isFullTime: isFullTime,
        ),
        annual: priceFor(
          MembershipPeriod.annual,
          sectionId: sectionId,
          isFullTime: isFullTime,
        ),
      );

  String nextSeatLabel(Iterable<String> existingLabels) {
    final labels = existingLabels.map((item) => item.trim()).toSet();
    if (seatNumbering.style == SeatNumberingStyle.numeric) {
      var number = seatNumbering.startingNumber;
      while (labels.contains('$number')) {
        number++;
      }
      return '$number';
    }

    final firstNumber = seatNumbering.startingNumber;
    final lastNumber = firstNumber + seatNumbering.numbersPerPrefix - 1;
    for (
      var code = seatNumbering.startPrefixCode;
      code <= seatNumbering.endPrefixCode;
      code++
    ) {
      final letter = String.fromCharCode(code);
      for (var number = firstNumber; number <= lastNumber; number++) {
        final label = '$letter$number';
        if (!labels.contains(label)) return label;
      }
    }
    return '${String.fromCharCode(seatNumbering.endPrefixCode)}${lastNumber + 1}';
  }

  LibraryConfiguration copyWith({
    Set<MembershipPeriod>? membershipPeriods,
    Map<MembershipPeriod, double>? planPrices,
    Set<LibrarySeatType>? seatTypes,
    List<LibrarySection>? sections,
    Set<StudentDocumentRequirement>? requiredDocuments,
    SeatNumberingConfiguration? seatNumbering,
    ShiftTimingConfiguration? shiftTimings,
  }) => LibraryConfiguration(
    membershipPeriods: membershipPeriods ?? this.membershipPeriods,
    planPrices: planPrices ?? this.planPrices,
    seatTypes: seatTypes ?? this.seatTypes,
    sections: sections ?? this.sections,
    requiredDocuments: requiredDocuments ?? this.requiredDocuments,
    seatNumbering: seatNumbering ?? this.seatNumbering,
    shiftTimings: shiftTimings ?? this.shiftTimings,
  );

  Map<String, dynamic> toMap() => {
    'seatTypes': seatTypes.map((item) => item.name).toList(),
    'sections': sections.map((item) => item.toMap()).toList(),
    'enabledStudentDocuments': requiredDocuments
        .map((item) => item.name)
        .toList(),
    'seatNumbering': seatNumbering.toMap(),
    'shiftTimings': shiftTimings.toMap(),
  };

  factory LibraryConfiguration.fromMap(Map<String, dynamic> value) {
    T? enumValue<T extends Enum>(Iterable<T> values, Object? name) {
      for (final item in values) {
        if (item.name == name) return item;
      }
      return null;
    }

    final membership = (value['membershipPlans'] as List<dynamic>?)
        ?.map((name) => enumValue(MembershipPeriod.values, name))
        .whereType<MembershipPeriod>()
        .toSet();
    final seatTypes = (value['seatTypes'] as List<dynamic>?)
        ?.map((name) {
          if (name == 'halfTimeShared') {
            return LibrarySeatType.halfTimeOpenSeating;
          }
          return enumValue(LibrarySeatType.values, name);
        })
        .whereType<LibrarySeatType>()
        .toSet();
    final documents =
        (value['enabledStudentDocuments'] as List<dynamic>? ??
                value['requiredStudentDocuments'] as List<dynamic>?)
            ?.map((name) => enumValue(StudentDocumentRequirement.values, name))
            .whereType<StudentDocumentRequirement>()
            .toSet();
    final priceValues = value['membershipPlanPrices'] is Map
        ? Map<String, dynamic>.from(value['membershipPlanPrices'] as Map)
        : const <String, dynamic>{};
    final prices = {
      for (final period in MembershipPeriod.values)
        period:
            (priceValues[period.name] as num?)?.toDouble() ??
            defaults.planPrices[period]!,
    };
    final effectiveMembership = membership == null || membership.isEmpty
        ? defaults.membershipPeriods
        : membership;
    final sectionValues = (value['sections'] as List<dynamic>?)
        ?.whereType<Map>()
        .map(
          (item) => LibrarySection.fromMap(
            Map<String, dynamic>.from(item),
            legacyPeriods: effectiveMembership,
            legacyPrices: prices,
          ),
        )
        .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList();
    final numberingValue = value['seatNumbering'] is Map
        ? Map<String, dynamic>.from(value['seatNumbering'] as Map)
        : <String, dynamic>{'style': value['seatNumberingStyle']};
    final storedNumberingStyle = numberingValue['style'];
    final numberingStyle =
        (storedNumberingStyle == 'mixed'
            ? SeatNumberingStyle.alphabetic
            : enumValue(SeatNumberingStyle.values, storedNumberingStyle)) ??
        defaults.seatNumbering.style;

    return LibraryConfiguration(
      membershipPeriods: effectiveMembership,
      planPrices: prices,
      seatTypes: seatTypes == null || seatTypes.isEmpty
          ? defaults.seatTypes
          : seatTypes,
      sections: sectionValues == null || sectionValues.isEmpty
          ? defaults.sections
          : sectionValues,
      requiredDocuments: documents ?? defaults.requiredDocuments,
      seatNumbering: SeatNumberingConfiguration(
        style: numberingStyle,
        startingNumber:
            (numberingValue['startingNumber'] as num?)?.toInt() ?? 1,
        endingNumber: (numberingValue['endingNumber'] as num?)?.toInt() ?? 100,
        prefix: (numberingValue['prefix'] as String?)?.trim().isNotEmpty == true
            ? (numberingValue['prefix'] as String).trim().toUpperCase()
            : 'A',
        endingPrefix:
            (numberingValue['endingPrefix'] as String?)?.trim().isNotEmpty ==
                true
            ? (numberingValue['endingPrefix'] as String).trim().toUpperCase()
            : ((numberingValue['prefix'] as String?) ?? 'A')
                  .trim()
                  .toUpperCase(),
        numbersPerPrefix:
            (numberingValue['numbersPerPrefix'] as num?)?.toInt() ?? 10,
      ),
      shiftTimings: value['shiftTimings'] is Map
          ? ShiftTimingConfiguration.fromMap(
              Map<String, dynamic>.from(value['shiftTimings'] as Map),
            )
          : const ShiftTimingConfiguration(),
    );
  }
}

extension SeatNumberingConfigurationValues on SeatNumberingConfiguration {
  int get startPrefixCode {
    final value = prefix.trim().toUpperCase();
    return (value.isEmpty ? 'A' : value[0]).codeUnitAt(0).clamp(65, 90);
  }

  int get endPrefixCode {
    final value = endingPrefix.trim().toUpperCase();
    return (value.isEmpty ? 'A' : value[0])
        .codeUnitAt(0)
        .clamp(startPrefixCode, 90);
  }
}

extension LibrarySeatTypeDetails on LibrarySeatType {
  String get label => switch (this) {
    LibrarySeatType.fullTimeReserved => 'Full-Time Reserved',
    LibrarySeatType.halfTimeOpenSeating => 'Half-Time Open Seating',
    LibrarySeatType.halfTimeReserved => 'Half-Time Reserved',
  };
}

extension DocumentRequirementDetails on StudentDocumentRequirement {
  String get label => switch (this) {
    StudentDocumentRequirement.studentPhoto => 'Student Photo',
    StudentDocumentRequirement.aadhaarCard => 'Aadhaar Card',
    StudentDocumentRequirement.addressProof => 'Address Proof',
    StudentDocumentRequirement.parentId => 'Parent ID',
    StudentDocumentRequirement.collegeId => 'College ID',
  };

  String get description => switch (this) {
    StudentDocumentRequirement.studentPhoto => 'Profile and identity photo',
    StudentDocumentRequirement.aadhaarCard => 'Front and back identity proof',
    StudentDocumentRequirement.addressProof => 'Current residential address',
    StudentDocumentRequirement.parentId => 'Parent or guardian identity',
    StudentDocumentRequirement.collegeId => 'Current institution identity',
  };
}
