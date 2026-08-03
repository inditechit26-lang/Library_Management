import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/payment_settings.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class PaymentSettingsController extends Notifier<PaymentSettings> {
  @override
  PaymentSettings build() {
    final config = ref.watch(libraryConfigProvider).value ?? const {};
    if (config['paymentSettings'] is Map) {
      return PaymentSettings.fromMap(
        Map<String, dynamic>.from(config['paymentSettings'] as Map),
      );
    }
    return const PaymentSettings();
  }

  Future<void> setActiveUpiId(String upiId) async {
    if (state.usesCustomQr) return;
    final trimmed = upiId.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(activeUpiId: trimmed);
    await _save(state);
  }

  Future<void> addUpiId(String upiId) async {
    if (state.usesCustomQr) return;
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
    if (state.usesCustomQr) return;
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
    final libraryId = ref.read(currentLibraryIdProvider) ?? 'default_library';

    final extension = fileName.contains('.') ? fileName.split('.').last : 'png';
    String url = '';
    try {
      url = await StorageService().uploadBytes(
        libraryId: libraryId,
        folderName: 'payment_qr',
        fileName: 'upi_qr.$extension',
        bytes: bytes,
        contentType: contentType,
      );
    } catch (e) {
      final base64String = base64Encode(bytes);
      url = 'data:$contentType;base64,$base64String';
    }
    state = state.copyWith(customQrUrl: url);
    await _save(state);
  }

  Future<void> removeCustomQr() async {
    final url = state.customQrUrl;
    state = state.copyWith(customQrUrl: '');
    await _save(state);
    if (url.isNotEmpty && !url.startsWith('data:')) {
      await StorageService().deleteFileByUrl(url);
    }
  }

  Future<void> _save(PaymentSettings value) async {
    await ref.read(settingsRepositoryProvider).updateLibraryConfig({
      'paymentSettings': value.toMap(),
    });
  }
}

final paymentSettingsProvider =
    NotifierProvider<PaymentSettingsController, PaymentSettings>(
      PaymentSettingsController.new,
    );
