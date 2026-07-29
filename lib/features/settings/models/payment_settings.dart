import 'package:flutter/foundation.dart';

@immutable
class PaymentSettings {
  final String activeUpiId;
  final List<String> upiIds;
  final String payeeName;
  final String customQrUrl;

  const PaymentSettings({
    this.activeUpiId = '',
    this.upiIds = const [],
    this.payeeName = '',
    this.customQrUrl = '',
  });

  PaymentSettings copyWith({
    String? activeUpiId,
    List<String>? upiIds,
    String? payeeName,
    String? customQrUrl,
  }) {
    return PaymentSettings(
      activeUpiId: activeUpiId ?? this.activeUpiId,
      upiIds: upiIds ?? this.upiIds,
      payeeName: payeeName ?? this.payeeName,
      customQrUrl: customQrUrl ?? this.customQrUrl,
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

  bool get usesCustomQr => customQrUrl.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'activeUpiId': activeUpiId,
    'upiIds': upiIds,
    'payeeName': payeeName,
    'customQrUrl': customQrUrl,
  };

  factory PaymentSettings.fromMap(Map<String, dynamic> value) =>
      PaymentSettings(
        activeUpiId: value['activeUpiId'] as String? ?? '',
        upiIds: (value['upiIds'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(),
        payeeName: value['payeeName'] as String? ?? '',
        customQrUrl: value['customQrUrl'] as String? ?? '',
      );
}
