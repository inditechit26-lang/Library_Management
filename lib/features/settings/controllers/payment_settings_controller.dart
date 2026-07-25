import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_settings.dart';

class PaymentSettingsController extends Notifier<PaymentSettings> {
  static const _activeUpiKey = 'payment_active_upi_id';
  static const _upiListKey = 'payment_upi_ids_list';
  static const _payeeNameKey = 'payment_payee_name';

  @override
  PaymentSettings build() {
    Future.microtask(_restore);
    return const PaymentSettings();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getString(_activeUpiKey) ?? 'thestudyroom@upi';
    final list = prefs.getStringList(_upiListKey) ?? [
      'thestudyroom@upi',
      '9527782347@ybl',
      'studydesk@okicici',
    ];
    final payee = prefs.getString(_payeeNameKey) ?? 'The Study Room';

    final updatedList = List<String>.from(list);
    if (!updatedList.contains(active) && active.isNotEmpty) {
      updatedList.add(active);
    }

    state = PaymentSettings(
      activeUpiId: active,
      upiIds: updatedList,
      payeeName: payee,
    );
  }

  Future<void> setActiveUpiId(String upiId) async {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(activeUpiId: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUpiKey, trimmed);
  }

  Future<void> addUpiId(String upiId) async {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty) return;
    final updatedList = List<String>.from(state.upiIds);
    if (!updatedList.contains(trimmed)) {
      updatedList.add(trimmed);
    }
    state = state.copyWith(activeUpiId: trimmed, upiIds: updatedList);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUpiKey, trimmed);
    await prefs.setStringList(_upiListKey, updatedList);
  }

  Future<void> removeUpiId(String upiId) async {
    final updatedList = List<String>.from(state.upiIds)..remove(upiId);
    String newActive = state.activeUpiId;
    if (newActive == upiId) {
      newActive = updatedList.isNotEmpty ? updatedList.first : '';
    }
    state = state.copyWith(activeUpiId: newActive, upiIds: updatedList);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUpiKey, newActive);
    await prefs.setStringList(_upiListKey, updatedList);
  }

  Future<void> setPayeeName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(payeeName: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_payeeNameKey, trimmed);
  }
}

final paymentSettingsProvider =
    NotifierProvider<PaymentSettingsController, PaymentSettings>(
  PaymentSettingsController.new,
);
