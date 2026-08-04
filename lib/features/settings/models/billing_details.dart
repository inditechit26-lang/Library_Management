class BillingDetails {
  const BillingDetails({
    this.businessName = '',
    this.address = '',
    this.phone = '',
    this.email = '',
  });

  final String businessName;
  final String address;
  final String phone;
  final String email;

  BillingDetails copyWith({
    String? businessName,
    String? address,
    String? phone,
    String? email,
  }) => BillingDetails(
    businessName: businessName ?? this.businessName,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    email: email ?? this.email,
  );
}
