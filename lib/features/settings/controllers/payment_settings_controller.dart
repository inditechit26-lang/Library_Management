import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/storage_service.dart';
import '../models/payment_settings.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class PaymentSettingsController extends Notifier<PaymentSettings> {
  static const _activeUpiKey = 'payment_active_upi_id';
  static const _upiListKey = 'payment_upi_ids_list';
  static const _payeeNameKey = 'payment_payee_name';

  @override
  PaymentSettings build() {
    final config = ref.watch(libraryConfigProvider).value ?? const {};
    if (config['paymentSettings'] is Map) {
      return PaymentSettings.fromMap(
        Map<String, dynamic>.from(config['paymentSettings'] as Map),
      );
    }
    Future.microtask(_restoreLegacy);
    return const PaymentSettings();
  }

  Future<void> _restoreLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getString(_activeUpiKey) ?? '';
    final list = prefs.getStringList(_upiListKey) ?? [];
    final payee = prefs.getString(_payeeNameKey) ?? '';

    final updatedList = List<String>.from(list);
    if (!updatedList.contains(active) && active.isNotEmpty) {
      updatedList.add(active);
    }

    final restored = PaymentSettings(
      activeUpiId: active,
      upiIds: updatedList,
      payeeName: payee,
    );
    if (restored.activeUpiId.isEmpty &&
        restored.upiIds.isEmpty &&
        restored.payeeName.isEmpty) {
      return;
    }
    state = restored;
    await _save(restored);
  }

  Future<void> setActiveUpiId(String upiId) async {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(activeUpiId: trimmed);
    await _save(state);
  }

  Future<void> addUpiId(String upiId) async {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty) return;
    final updatedList = List<String>.from(state.upiIds);
    if (!updatedList.contains(trimmed)) {
      updatedList.add(trimmed);
    }
    state = state.copyWith(activeUpiId: trimmed, upiIds: updatedList);
    await _save(state);
  }

  Future<void> removeUpiId(String upiId) async {
    final updatedList = List<String>.from(state.upiIds)..remove(upiId);
    String newActive = state.activeUpiId;
    if (newActive == upiId) {
      newActive = updatedList.isNotEmpty ? updatedList.first : '';
    }
    state = state.copyWith(activeUpiId: newActive, upiIds: updatedList);
    await _save(state);
  }

  Future<void> setPayeeName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(payeeName: trimmed);
    await _save(state);
  }

  Future<void> uploadCustomQr({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) {
      throw StateError('Select a library before uploading a QR code.');
    }

    final extension = fileName.contains('.') ? fileName.split('.').last : 'png';
    final url = await StorageService().uploadBytes(
      libraryId: libraryId,
      folderName: 'payment_qr',
      fileName: 'upi_qr.$extension',
      bytes: bytes,
      contentType: contentType,
    );
    state = state.copyWith(customQrUrl: url);
    await _save(state);
  }

  Future<void> removeCustomQr() async {
    final url = state.customQrUrl;
    state = state.copyWith(customQrUrl: '');
    await _save(state);
    if (url.isNotEmpty) await StorageService().deleteFileByUrl(url);
  }

  Future<void> _save(PaymentSettings value) async {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) return;
    await ref.read(settingsRepositoryProvider).updateLibraryConfig(libraryId, {
      'paymentSettings': value.toMap(),
    });
  }
}

final paymentSettingsProvider =
    NotifierProvider<PaymentSettingsController, PaymentSettings>(
      PaymentSettingsController.new,
    );
