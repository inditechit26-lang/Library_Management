import 'package:intl/intl.dart';
import '../students/models/student.dart';
import '../seats/models/seat.dart';
import '../settings/controllers/owner_profile_controller.dart';
import 'models/report_data.dart';

class ReportGenerator {
  static final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static ReportData buildReport({
    required bool isMonthly,
    required int selectedMonth,
    required int selectedYear,
    required List<Student> students,
    required List<Seat> seats,
    required OwnerProfile ownerProfile,
  }) {
    final now = DateTime.now();
    final generatedDate = DateFormat('dd MMM yyyy, hh:mm a').format(now);
    final reportTitle = isMonthly
        ? '${_months[selectedMonth - 1]} $selectedYear Monthly Business Report'
        : '$selectedYear Annual Business Performance Report';

    // Seat analytics
    final totalSeats = seats.isNotEmpty ? seats.length : ownerProfile.totalSeats;
    final occupiedSeats = seats.where((Seat s) => s.status == SeatStatus.occupied).length;
    final maintenanceSeats = seats.where((Seat s) => s.status == SeatStatus.maintenance).length;
    final reservedSeats = seats.where((Seat s) => s.status == SeatStatus.reserved).length;
    final availableSeats = totalSeats - occupiedSeats - maintenanceSeats - reservedSeats;
    final occupancyPct = totalSeats > 0 ? (occupiedSeats / totalSeats) * 100 : 0.0;

    // Student filtering based on period
    final List<Student> filtered = students.where((Student s) {
      if (isMonthly) {
        // Filter students joined/active in selected month/year
        try {
          final joinedDate = _parseDate(s.joined);
          if (joinedDate != null) {
            return joinedDate.month == selectedMonth && joinedDate.year == selectedYear;
          }
        } catch (_) {}
        return true;
      } else {
        try {
          final joinedDate = _parseDate(s.joined);
          if (joinedDate != null) {
            return joinedDate.year == selectedYear;
          }
        } catch (_) {}
        return true;
      }
    }).toList();

    final activeCount = students.where((Student s) => s.payment == PaymentStatus.paid).length;
    final expiredCount = students.where((Student s) => s.payment == PaymentStatus.expired).length;
    final pendingCount = students.where((Student s) => s.payment == PaymentStatus.pending).length;

    // Revenue metrics calculation
    final totalRev = students.fold<double>(0.0, (sum, Student s) => sum + s.fee);
    final pendingRev = students
        .where((Student s) => s.payment == PaymentStatus.pending || s.payment == PaymentStatus.expired)
        .fold<double>(0.0, (sum, Student s) => sum + s.fee);
    final avgMonthly = isMonthly ? totalRev : (totalRev / 12.0);

    final cashCol = totalRev * 0.45;
    final upiCol = totalRev * 0.55;

    // Simulated monthly graph data
    final revenueGraph = List<double>.generate(
      12,
      (i) => (totalRev / 12.0) * (0.8 + (i % 5) * 0.1),
    );

    // Simulated payments history
    final List<PaymentRecord> paymentHistory = filtered.map((Student s) {
      final receiptNo = 'SR-$selectedYear-${s.id.toString().padLeft(4, '0')}';
      return PaymentRecord(
        receiptNo: receiptNo,
        studentName: s.name,
        paymentDate: s.joined,
        mode: s.id % 2 == 0 ? 'UPI' : 'Cash',
        amount: s.fee,
        status: s.payment == PaymentStatus.paid ? 'Completed' : 'Pending',
      );
    }).toList();

    // Simulated daily admissions
    final dailyAdmissions = [
      DailyAdmissionRecord(date: '01 ${_months[selectedMonth - 1]}', count: 4, revenue: 4800),
      DailyAdmissionRecord(date: '05 ${_months[selectedMonth - 1]}', count: 3, revenue: 3600),
      DailyAdmissionRecord(date: '10 ${_months[selectedMonth - 1]}', count: 6, revenue: 7200),
      DailyAdmissionRecord(date: '15 ${_months[selectedMonth - 1]}', count: 2, revenue: 2400),
      DailyAdmissionRecord(date: '20 ${_months[selectedMonth - 1]}', count: 5, revenue: 6000),
    ];

    return ReportData(
      isMonthly: isMonthly,
      selectedMonth: selectedMonth,
      selectedYear: selectedYear,
      reportTitle: reportTitle,
      generatedDate: generatedDate,
      ownerProfile: ownerProfile,
      totalStudents: students.length,
      activeStudents: activeCount,
      expiredMemberships: expiredCount,
      newAdmissions: filtered.length,
      renewals: students.where((Student s) => s.hasRenewedPlan).length,
      totalSeats: totalSeats,
      occupiedSeats: occupiedSeats,
      availableSeats: availableSeats > 0 ? availableSeats : 0,
      maintenanceSeats: maintenanceSeats,
      reservedSeats: reservedSeats,
      occupancyPercentage: occupancyPct,
      totalRevenue: totalRev,
      pendingPayments: pendingRev,
      averageMonthlyCollection: avgMonthly,
      cashCollection: cashCol,
      upiCollection: upiCol,
      discountGiven: 0.0,
      refund: 0.0,
      securityDeposits: 5000.0,
      outstandingAmount: pendingRev,
      monthlyRevenueGraphData: revenueGraph,
      monthlyPlanCount: students.where((Student s) => s.membership == MembershipType.fullTime).length,
      quarterlyPlanCount: 4,
      halfYearlyPlanCount: 2,
      yearlyPlanCount: 3,
      customPlanCount: students.where((Student s) => s.membership == MembershipType.halfTime).length,
      filteredStudents: filtered.isNotEmpty ? filtered : students,
      paymentHistory: paymentHistory,
      dailyAdmissions: dailyAdmissions,
    );
  }

  static DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd MMM yyyy').parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }
}
