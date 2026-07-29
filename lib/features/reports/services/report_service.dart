import 'package:intl/intl.dart';
import '../../students/models/student.dart';
import '../../seats/models/seat.dart';
import '../../settings/controllers/owner_profile_controller.dart';
import '../models/report_data.dart';

class ReportService {
  static final DateFormat _df = DateFormat('dd MMM yyyy');

  /// Parse String date safely into DateTime
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return _df.parse(dateStr.trim());
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }

  /// Check if date is within range [start, end] inclusive (by day)
  static bool isDateInRange(DateTime target, DateTime start, DateTime end) {
    final t = DateTime(target.year, target.month, target.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return (t.isAfter(s) || t.isAtSameMomentAs(s)) &&
        (t.isBefore(e) || t.isAtSameMomentAs(e));
  }

  /// Generate ReportData for Monthly, Yearly or Custom ranges
  static ReportData buildReportData({
    required String reportType,
    required String selectedPeriod,
    required DateTime startDate,
    required DateTime endDate,
    required List<Student> allStudents,
    required List<Seat> allSeats,
    required OwnerProfile ownerProfile,
    Map<String, String> sectionNames = const {},
  }) {
    final now = DateTime.now();

    // Filter students active/joined within period
    final periodStudents = allStudents.where((s) {
      final jDate = parseDate(s.joined);
      if (jDate == null) return true;
      return isDateInRange(jDate, startDate, endDate);
    }).toList();

    int newAdmissions = 0;
    int renewals = 0;
    int expiredMemberships = 0;
    double cashCollection = 0.0;
    double upiCollection = 0.0;
    double bankCollection = 0.0;
    double totalCollection = 0.0;
    double pendingFees = 0.0;

    final List<PaymentRecord> history = [];
    final revenueBySection = <String, double>{};

    for (var s in periodStudents) {
      if (s.hasRenewedPlan) {
        renewals++;
      } else {
        newAdmissions++;
      }
      if (s.payment == PaymentStatus.expired) expiredMemberships++;

      final fee = s.fee;
      if (s.payment == PaymentStatus.paid) {
        totalCollection += fee;
        final sectionName =
            sectionNames[s.sectionId] ?? s.sectionId ?? 'Unassigned';
        revenueBySection.update(
          sectionName,
          (value) => value + fee,
          ifAbsent: () => fee,
        );
        if (s.paymentMode == PaymentMode.cash) {
          cashCollection += fee;
        } else {
          upiCollection += fee;
        }

        history.add(
          PaymentRecord(
            receiptNo: '',
            studentName: s.name,
            paymentDate: s.joined,
            mode: s.paymentMode.label,
            amount: s.fee,
            status: 'Paid',
          ),
        );
      } else {
        pendingFees += fee;
      }
    }

    final occupiedSeats = allSeats
        .where((s) => s.status == SeatStatus.occupied)
        .length;
    final availableSeats = allSeats
        .where((s) => s.status == SeatStatus.available)
        .length;

    return ReportData(
      reportType: reportType,
      selectedPeriod: selectedPeriod,
      generatedDate: DateFormat('dd MMM yyyy, hh:mm a').format(now),
      ownerProfile: ownerProfile,
      totalStudents: periodStudents.length,
      newAdmissions: newAdmissions,
      renewals: renewals,
      expiredMemberships: expiredMemberships,
      occupiedSeats: occupiedSeats,
      availableSeats: availableSeats,
      totalCollection: totalCollection,
      pendingFees: pendingFees,
      cashPayment: cashCollection,
      upiPayment: upiCollection,
      bankPayment: bankCollection,
      totalRevenue: totalCollection,
      studentList: periodStudents,
      paymentHistory: history,
      revenueBySection: revenueBySection,
      sectionNames: sectionNames,
    );
  }
}
