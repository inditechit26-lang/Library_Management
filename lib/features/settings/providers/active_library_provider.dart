import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../repositories/library_repository.dart';

class LibraryModel {
  const LibraryModel({
    required this.id,
    required this.name,
    required this.ownerName,
    this.logoUrl,
    this.icon = Icons.apartment_rounded,
  });

  final String id;
  final String name;
  final String ownerName;
  final String? logoUrl;
  final IconData icon;

  LibraryModel copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? logoUrl,
    IconData? icon,
  }) => LibraryModel(
    id: id ?? this.id,
    name: name ?? this.name,
    ownerName: ownerName ?? this.ownerName,
    logoUrl: logoUrl ?? this.logoUrl,
    icon: icon ?? this.icon,
  );
}

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(),
);

final librariesProvider = StreamProvider<List<LibraryModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(_demoLibraries);

  return ref
      .watch(libraryRepositoryProvider)
      .watchLibraries(user.uid)
      .map(
        (records) => records.map(_libraryFromRecord).toList(growable: false),
      );
});

LibraryModel _libraryFromRecord(LibraryRecord record) {
  final info = Map<String, dynamic>.from(
    record.data['libraryInfo'] as Map? ?? const <String, dynamic>{},
  );
  final branding = Map<String, dynamic>.from(
    record.data['branding'] as Map? ?? const <String, dynamic>{},
  );
  return LibraryModel(
    id: record.id,
    name: info['name'] as String? ?? 'Library',
    ownerName: info['ownerName'] as String? ?? 'Owner',
    logoUrl: branding['logoUrl'] as String?,
  );
}

class ActiveLibraryNotifier extends Notifier<LibraryModel> {
  List<LibraryModel> _libraries = _demoLibraries;

  @override
  LibraryModel build() {
    final user = ref.watch(authStateProvider).value;
    final currentId = ref.watch(currentLibraryIdProvider);
    final streamedLibraries = ref.watch(librariesProvider).value;
    if (streamedLibraries != null) {
      _libraries = streamedLibraries;
    } else if (user == null) {
      _libraries = _demoLibraries;
    }
    return _activeOrFallback(currentId);
  }

  LibraryModel _activeOrFallback(String? currentId) {
    if (_libraries.isNotEmpty) {
      return _libraries.firstWhere(
        (library) => library.id == currentId,
        orElse: () => _libraries.first,
      );
    }
    return LibraryModel(
      id: currentId ?? '',
      name: 'My Study Library',
      ownerName: 'Owner',
    );
  }

  Future<void> selectLibrary(LibraryModel library) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      state = library;
      return;
    }
    try {
      await ref
          .read(authRepositoryProvider)
          .switchCurrentLibrary(user.uid, library.id);
    } catch (_) {
      // Allow fallback switching for local demo libraries
    }
    state = library;
  }

  Future<void> addLibrary(String name) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      final library = LibraryModel(
        id: 'lib_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        ownerName: 'Owner',
      );
      _libraries = [..._libraries, library];
      state = library;
      return;
    }
    await ref
        .read(authRepositoryProvider)
        .createLibraryForUser(uid: user.uid, libraryName: name);
  }
}

const _demoLibraries = <LibraryModel>[
  LibraryModel(id: 'lib_1', name: 'Bright Minds Library', ownerName: 'Owner'),
  LibraryModel(id: 'lib_2', name: 'Central Study Library', ownerName: 'Owner'),
  LibraryModel(id: 'lib_3', name: 'Apex Scholars Hub', ownerName: 'Owner'),
];

final activeLibraryProvider =
    NotifierProvider<ActiveLibraryNotifier, LibraryModel>(
      ActiveLibraryNotifier.new,
    );
