import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class OwnerProfileNotifier extends StateNotifier<OwnerProfile> {
  OwnerProfileNotifier()
      : super(const OwnerProfile(
          name: 'StudyDesk Owner',
          email: 'owner@thestudyroom.in',
          phone: '+91 98765 43210',
          libraryName: 'StudyDesk Central Library',
          branchName: 'Main Branch (Connaught Place)',
          address: 'Plot 42, Knowledge Park, Sector 62, New Delhi',
          openingTime: '06:00 AM',
          closingTime: '11:00 PM',
          totalSeats: 120,
          subscriptionPlan: 'Library Pro Unlimited',
          joinDate: '12 Jan 2025',
        ));

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
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      libraryName: libraryName,
      branchName: branchName,
      address: address,
      openingTime: openingTime,
      closingTime: closingTime,
    );
  }
}

final ownerProfileProvider =
    StateNotifierProvider<OwnerProfileNotifier, OwnerProfile>(
  (ref) => OwnerProfileNotifier(),
);
