import 'package:flutter/foundation.dart';

@immutable
class PaymentSettings {
  final String activeUpiId;
  final List<String> upiIds;
  final String payeeName;

  const PaymentSettings({
    this.activeUpiId = '',
    this.upiIds = const [],
    this.payeeName = '',
  });

  PaymentSettings copyWith({
    String? activeUpiId,
    List<String>? upiIds,
    String? payeeName,
  }) {
    return PaymentSettings(
      activeUpiId: activeUpiId ?? this.activeUpiId,
      upiIds: upiIds ?? this.upiIds,
      payeeName: payeeName ?? this.payeeName,
    );
  }

  String getQrData([double amount = 0.0]) {
    final cleanUpi = activeUpiId.trim();
    final cleanName = Uri.encodeComponent(payeeName.trim());
    if (amount > 0) {
      return 'upi://pay?pa=$cleanUpi&pn=$cleanName&am=$amount&cu=INR';
    }
    return 'upi://pay?pa=$cleanUpi&pn=$cleanName&cu=INR';
  }
}
