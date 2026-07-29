import '../../students/models/student.dart';
import '../../settings/controllers/owner_profile_controller.dart';

class PaymentRecord {
  final String receiptNo;
  final String studentName;
  final String paymentDate;
  final String mode;
  final double amount;
  final String status;

  const PaymentRecord({
    required this.receiptNo,
    required this.studentName,
    required this.paymentDate,
    required this.mode,
    required this.amount,
    required this.status,
  });
}

class ReportData {
  final String reportType; // Monthly, Yearly, Custom
  final String selectedPeriod;
  final String generatedDate;
  final OwnerProfile ownerProfile;

  // Summary Metrics
  final int totalStudents;
  final int newAdmissions;
  final int renewals;
  final int expiredMemberships;
  final int occupiedSeats;
  final int availableSeats;
  final double totalCollection;
  final double pendingFees;

  // Payment Breakdown
  final double cashPayment;
  final double upiPayment;
  final double bankPayment;
  final double totalRevenue;

  // Lists
  final List<Student> studentList;
  final List<PaymentRecord> paymentHistory;
  final Map<String, double> revenueBySection;
  final Map<String, String> sectionNames;

  const ReportData({
    required this.reportType,
    required this.selectedPeriod,
    required this.generatedDate,
    required this.ownerProfile,
    required this.totalStudents,
    required this.newAdmissions,
    required this.renewals,
    required this.expiredMemberships,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.totalCollection,
    required this.pendingFees,
    required this.cashPayment,
    required this.upiPayment,
    required this.bankPayment,
    required this.totalRevenue,
    required this.studentList,
    required this.paymentHistory,
    this.revenueBySection = const {},
    this.sectionNames = const {},
  });
}
