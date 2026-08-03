import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class OwnerProfile {
  final String name;
  final String email;
  final String phone;
  final String libraryName;
  final String branchName;
  final String address;
  final String openingTime;
  final String closingTime;
  final int totalSeats;
  final String subscriptionPlan;
  final String joinDate;

  const OwnerProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.libraryName,
    required this.branchName,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.totalSeats,
    required this.subscriptionPlan,
    required this.joinDate,
  });

  OwnerProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? libraryName,
    String? branchName,
    String? address,
    String? openingTime,
    String? closingTime,
    int? totalSeats,
    String? subscriptionPlan,
    String? joinDate,
  }) {
    return OwnerProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      libraryName: libraryName ?? this.libraryName,
      branchName: branchName ?? this.branchName,
      address: address ?? this.address,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      totalSeats: totalSeats ?? this.totalSeats,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class OwnerProfileNotifier extends Notifier<OwnerProfile> {
  @override
  OwnerProfile build() {
    final profile = ref.watch(userProfileProvider).value;
    final info = ref.watch(libraryInfoProvider).value ?? const {};
    final config = ref.watch(libraryConfigProvider).value ?? const {};
    return OwnerProfile(
      name: (info['ownerName'] as String?) ?? profile?.displayName ?? '',
      email: (info['email'] as String?) ?? profile?.email ?? '',
      phone: (info['phone'] as String?) ?? '',
      libraryName: (info['name'] as String?) ?? '',
      branchName: (info['branchName'] as String?) ?? '',
      address: (info['address'] as String?) ?? '',
      openingTime: (info['openingTime'] as String?) ?? '',
      closingTime: (info['closingTime'] as String?) ?? '',
      totalSeats: (config['totalSeats'] as num?)?.toInt() ?? 0,
      subscriptionPlan: (config['subscriptionPlan'] as String?) ?? '',
      joinDate: '',
    );
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? libraryName,
    String? branchName,
    String? address,
    String? openingTime,
    String? closingTime,
  }) {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) return;
    final updates = <String, dynamic>{
      if (name != null) 'ownerName': name.trim(),
      if (email != null) 'email': email.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (libraryName != null) 'name': libraryName.trim(),
      if (branchName != null) 'branchName': branchName.trim(),
      if (address != null) 'address': address.trim(),
      if (openingTime != null) 'openingTime': openingTime.trim(),
      if (closingTime != null) 'closingTime': closingTime.trim(),
    };
    if (updates.isEmpty) return;
    unawaited(ref.read(settingsRepositoryProvider).updateLibraryInfo(updates));
  }
}

final ownerProfileProvider =
    NotifierProvider<OwnerProfileNotifier, OwnerProfile>(
      OwnerProfileNotifier.new,
    );
