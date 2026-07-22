import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../settings/models/pricing_settings.dart';
import '../../students/models/student.dart';

class AdmissionController extends ChangeNotifier {
  AdmissionController(this.pricing);
  PricingSettings pricing;
  int step = 0;
  MembershipType membership = MembershipType.fullTime;
  MembershipPeriod? period;
  String? selectedSeat;
  bool paymentConfirmed = false;
  bool completed = false;
  final Set<String> documents = {};
  DateTime customStart = DateTime.now();
  DateTime? customEnd;
  int? customDays;
  double? customAmount;

  double get fee => period == MembershipPeriod.custom
      ? customAmount ?? _calculatedCustomFee
      : period == null
      ? 0
      : pricing.forMembership(membership).priceFor(period!);
  DateTime get joiningDate =>
      period == MembershipPeriod.custom ? customStart : DateTime.now();
  DateTime get expiryDate {
    if (period == MembershipPeriod.custom) {
      return customEnd ??
          customStart.add(Duration(days: customDays?.clamp(1, 100000) ?? 1));
    }
    final months = period?.months ?? 0;
    return DateTime(
      joiningDate.year,
      joiningDate.month + months,
      joiningDate.day,
    );
  }

  int get totalDays => expiryDate.difference(joiningDate).inDays;
  double get _calculatedCustomFee {
    if (customEnd == null || totalDays <= 0) return 0;
    final monthlyRate = pricing.forMembership(membership).monthly;
    return (monthlyRate / 30 * totalDays).roundToDouble();
  }

  String get joined => DateFormat('dd MMM yyyy').format(joiningDate);
  String get expiry => DateFormat('dd MMM yyyy').format(expiryDate);
  String get joiningDisplay => DateFormat('d MMMM yyyy').format(joiningDate);
  String get expiryDisplay => DateFormat('d MMMM yyyy').format(expiryDate);
  String get duration => period == MembershipPeriod.custom
      ? '$totalDays ${totalDays == 1 ? 'Day' : 'Days'}'
      : period?.duration ?? '';
  bool get pricingValid =>
      period != null &&
      (period != MembershipPeriod.custom ||
          (customEnd != null && fee >= 0 && totalDays > 0));

  void updatePricing(PricingSettings value) {
    pricing = value;
  }

  void chooseMembership(MembershipType value) {
    membership = value;
    if (value == MembershipType.halfTime) selectedSeat = null;
    notifyListeners();
  }

  void choosePeriod(MembershipPeriod value) {
    period = value;
    paymentConfirmed = false;
    notifyListeners();
  }

  void setCustomStart(DateTime value) {
    customStart = value;
    if (customEnd != null && customEnd!.isBefore(value)) {
      customEnd = null;
      customDays = null;
      customAmount = null;
    } else if (customEnd != null) {
      customDays = customEnd!.difference(customStart).inDays;
      customAmount = _calculatedCustomFee;
    }
    notifyListeners();
  }

  void setCustomEnd(DateTime value) {
    if (value.isBefore(customStart)) return;
    customEnd = value;
    customDays = value.difference(customStart).inDays;
    customAmount = _calculatedCustomFee;
    notifyListeners();
  }

  void setCustomDays(int? value) {
    customDays = value;
    if (value != null && value > 0) {
      customEnd = customStart.add(Duration(days: value));
      customAmount = _calculatedCustomFee;
    } else {
      customEnd = null;
      customAmount = null;
    }
    notifyListeners();
  }

  void setCustomAmount(double? value) {
    customAmount = value;
    notifyListeners();
  }

  void chooseSeat(String value) {
    selectedSeat = value;
    notifyListeners();
  }

  void setPaymentConfirmed(bool value) {
    paymentConfirmed = value;
    notifyListeners();
  }

  void toggleDocument(String value) {
    documents.contains(value) ? documents.remove(value) : documents.add(value);
    notifyListeners();
  }

  void next() {
    if (step < 4) step++;
    notifyListeners();
  }

  void back() {
    if (step > 0) step--;
    notifyListeners();
  }

  Student create({
    required int id,
    required String name,
    required String phone,
    String emergencyContact = '',
    String notes = '',
  }) {
    final parts = name.trim().split(RegExp(r'\s+'));
    completed = true;
    notifyListeners();
    return Student(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      emergencyContact: emergencyContact.trim(),
      notes: notes.trim(),
      seat: membership == MembershipType.fullTime
          ? selectedSeat ?? ''
          : 'Flexible',
      joined: joined,
      expiry: expiry,
      fee: fee,
      payment: paymentConfirmed ? PaymentStatus.paid : PaymentStatus.pending,
      membership: membership,
      initials: parts
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => part[0].toUpperCase())
          .join(),
    );
  }
}
