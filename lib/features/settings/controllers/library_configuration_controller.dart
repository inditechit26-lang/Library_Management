import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/library_configuration.dart';
import '../providers/settings_provider.dart';
import '../../seats/controllers/seats_controller.dart';

class LibraryConfigurationController extends Notifier<LibraryConfiguration> {
  @override
  LibraryConfiguration build() {
    final value = ref.watch(libraryConfigProvider).value ?? const {};
    final configuration = value['libraryConfiguration'];
    if (configuration is Map) {
      return LibraryConfiguration.fromMap(
        Map<String, dynamic>.from(configuration),
      );
    }
    return LibraryConfiguration.defaults;
  }

  Future<void> save(LibraryConfiguration value) async {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) return;
    final numberingChanged =
        state.seatNumbering.toMap().toString() !=
        value.seatNumbering.toMap().toString();
    state = value;
    await ref.read(settingsRepositoryProvider).updateLibraryConfig(libraryId, {
      'libraryConfiguration': value.toMap(),
    });
    if (numberingChanged) {
      await ref
          .read(seatsProvider.notifier)
          .applyNumbering(value.seatNumbering);
    }
  }
}

final libraryConfigurationProvider =
    NotifierProvider<LibraryConfigurationController, LibraryConfiguration>(
      LibraryConfigurationController.new,
    );
