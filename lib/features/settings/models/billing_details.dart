class BillingDetails {
  const BillingDetails({
    this.businessName = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.taxId = '',
    this.receiptPrefix = 'SH',
    this.footerMessage = '',
  });

  final String businessName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String taxId;
  final String receiptPrefix;
  final String footerMessage;

  BillingDetails copyWith({
    String? businessName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? taxId,
    String? receiptPrefix,
    String? footerMessage,
  }) => BillingDetails(
    businessName: businessName ?? this.businessName,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    website: website ?? this.website,
    taxId: taxId ?? this.taxId,
    receiptPrefix: receiptPrefix ?? this.receiptPrefix,
    footerMessage: footerMessage ?? this.footerMessage,
  );
}
