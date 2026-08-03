import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryModel {
  final String id;
  final String name;
  final String ownerName;
  final String? logoUrl;
  final IconData icon;

  const LibraryModel({
    required this.id,
    required this.name,
    required this.ownerName,
    this.logoUrl,
    this.icon = Icons.apartment_rounded,
  });

  LibraryModel copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? logoUrl,
    IconData? icon,
  }) {
    return LibraryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      logoUrl: logoUrl ?? this.logoUrl,
      icon: icon ?? this.icon,
    );
  }
}

class ActiveLibraryNotifier extends Notifier<LibraryModel> {
  final List<LibraryModel> _libraries = [
    const LibraryModel(
      id: 'lib_1',
      name: 'Bright Minds Library',
      ownerName: 'Owner',
      icon: Icons.apartment_rounded,
    ),
    const LibraryModel(
      id: 'lib_2',
      name: 'Central Study Library',
      ownerName: 'Owner',
      icon: Icons.local_library_rounded,
    ),
    const LibraryModel(
      id: 'lib_3',
      name: 'Apex Scholars Hub',
      ownerName: 'Owner',
      icon: Icons.business_center_rounded,
    ),
  ];

  @override
  LibraryModel build() {
    return _libraries.first;
  }

  List<LibraryModel> get libraries => List.unmodifiable(_libraries);

  void selectLibrary(LibraryModel library) {
    state = library;
  }

  void addLibrary(String name) {
    final newLib = LibraryModel(
      id: 'lib_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      ownerName: 'Owner',
      icon: Icons.business_rounded,
    );
    _libraries.add(newLib);
    state = newLib;
  }
}

final activeLibraryProvider =
    NotifierProvider<ActiveLibraryNotifier, LibraryModel>(
  ActiveLibraryNotifier.new,
);
