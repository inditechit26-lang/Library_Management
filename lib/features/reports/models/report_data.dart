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

class DailyAdmissionRecord {
  const DailyAdmissionRecord({
    required this.date,
    required this.count,
    required this.revenue,
  });
  final String date;
  final int count;
  final double revenue;
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

  // Extended analytics used by the detailed report builder.
  final String reportTitle;
  final int activeStudents;
  final int totalSeats;
  final int maintenanceSeats;
  final int reservedSeats;
  final double occupancyPercentage;
  final double pendingPayments;
  final double averageMonthlyCollection;
  final double cashCollection;
  final double upiCollection;
  final double discountGiven;
  final double refund;
  final double securityDeposits;
  final double outstandingAmount;
  final List<double> monthlyRevenueGraphData;
  final int monthlyPlanCount;
  final int quarterlyPlanCount;
  final int halfYearlyPlanCount;
  final int yearlyPlanCount;
  final int customPlanCount;
  final List<Student> filteredStudents;
  final List<DailyAdmissionRecord> dailyAdmissions;

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
    this.reportTitle = '',
    this.activeStudents = 0,
    this.totalSeats = 0,
    this.maintenanceSeats = 0,
    this.reservedSeats = 0,
    this.occupancyPercentage = 0,
    this.pendingPayments = 0,
    this.averageMonthlyCollection = 0,
    this.cashCollection = 0,
    this.upiCollection = 0,
    this.discountGiven = 0,
    this.refund = 0,
    this.securityDeposits = 0,
    this.outstandingAmount = 0,
    this.monthlyRevenueGraphData = const [],
    this.monthlyPlanCount = 0,
    this.quarterlyPlanCount = 0,
    this.halfYearlyPlanCount = 0,
    this.yearlyPlanCount = 0,
    this.customPlanCount = 0,
    this.filteredStudents = const [],
    this.dailyAdmissions = const [],
  });
}
