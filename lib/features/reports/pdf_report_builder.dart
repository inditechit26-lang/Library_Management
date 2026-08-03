import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'models/report_data.dart';

class PdfReportBuilder {
  static Future<Uint8List> generatePdf(ReportData report) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#574DEB');
    final darkColor = PdfColor.fromHex('#1E1E2D');
    final greyColor = PdfColor.fromHex('#6C757D');
    final lightBg = PdfColor.fromHex('#F8F9FA');

    // Page 1: Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    report.ownerProfile.libraryName.isNotEmpty
                        ? report.ownerProfile.libraryName
                        : 'StudyDesk Library',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  report.generatedDate,
                  style: pw.TextStyle(color: greyColor, fontSize: 10),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BUSINESS REPORT',
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    report.reportTitle,
                    style: pw.TextStyle(
                      color: darkColor,
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Prepared By: ${report.ownerProfile.name}',
                        style: pw.TextStyle(color: darkColor, fontSize: 11),
                      ),
                      pw.Text(
                        'Branch: ${report.ownerProfile.branchName}',
                        style: pw.TextStyle(color: darkColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Spacer(),
          ],
        ),
      ),
    );

    // Page 2: Executive Summary
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Executive Summary', primaryColor),
            pw.SizedBox(height: 20),
            pw.GridView(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              children: [
                _buildMetricBox(
                  'Total Students',
                  '${report.totalStudents}',
                  primaryColor,
                ),
                _buildMetricBox(
                  'Active Students',
                  '${report.activeStudents}',
                  PdfColors.green700,
                ),
                _buildMetricBox(
                  'Expired Memberships',
                  '${report.expiredMemberships}',
                  PdfColors.red700,
                ),
                _buildMetricBox(
                  'New Admissions',
                  '${report.newAdmissions}',
                  primaryColor,
                ),
                _buildMetricBox(
                  'Renewals',
                  '${report.renewals}',
                  PdfColors.blue700,
                ),
                _buildMetricBox(
                  'Occupancy Rate',
                  '${report.occupancyPercentage.toStringAsFixed(1)}%',
                  primaryColor,
                ),
                _buildMetricBox(
                  'Total Revenue',
                  '₹${report.totalRevenue.toInt()}',
                  PdfColors.green800,
                ),
                _buildMetricBox(
                  'Pending Payments',
                  '₹${report.pendingPayments.toInt()}',
                  PdfColors.orange700,
                ),
                _buildMetricBox(
                  'Avg Monthly Collection',
                  '₹${report.averageMonthlyCollection.toInt()}',
                  primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Page 3: Financial Summary
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Financial Summary', primaryColor),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Metric', 'Amount (₹)'],
              data: [
                ['Total Collection', '₹${report.totalRevenue.toInt()}'],
                ['Cash Collection', '₹${report.cashCollection.toInt()}'],
                ['UPI Collection', '₹${report.upiCollection.toInt()}'],
                ['Discount Given', '₹${report.discountGiven.toInt()}'],
                ['Refunds Processed', '₹${report.refund.toInt()}'],
                ['Security Deposits', '₹${report.securityDeposits.toInt()}'],
                ['Outstanding Amount', '₹${report.outstandingAmount.toInt()}'],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );

    // Page 4: Membership Summary
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Membership Summary', primaryColor),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Plan Type', 'Active Subscriptions'],
              data: [
                ['Monthly Plan (Full Day)', '${report.monthlyPlanCount}'],
                ['Quarterly Plan', '${report.quarterlyPlanCount}'],
                ['Half Yearly Plan', '${report.halfYearlyPlanCount}'],
                ['Yearly Plan', '${report.yearlyPlanCount}'],
                ['Custom / Half Day Plans', '${report.customPlanCount}'],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );

    // Page 5: Admissions & Renewals
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Admissions & Renewals', primaryColor),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'New Students Joined', 'Revenue Generated'],
              data: report.dailyAdmissions
                  .map(
                    (rec) => [
                      rec.date,
                      '${rec.count}',
                      '₹${rec.revenue.toInt()}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );

    // Page 6: Seat Analytics
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Seat Analytics', primaryColor),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Seat Category', 'Count', 'Percentage'],
              data: [
                ['Total Capacity', '${report.totalSeats}', '100%'],
                [
                  'Occupied Seats',
                  '${report.occupiedSeats}',
                  '${report.occupancyPercentage.toStringAsFixed(1)}%',
                ],
                [
                  'Available Seats',
                  '${report.availableSeats}',
                  '${(100 - report.occupancyPercentage).toStringAsFixed(1)}%',
                ],
                ['Under Maintenance', '${report.maintenanceSeats}', '-'],
                ['Reserved Seats', '${report.reservedSeats}', '-'],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );

    // Page 7: Student List
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Student List Directory', primaryColor),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Name', 'Seat', 'Expiry', 'Amount'],
              data: report.filteredStudents
                  .take(15)
                  .map(
                    (s) => [
                      '${s.id}',
                      s.name,
                      s.seat,
                      s.expiry,
                      '₹${s.fee.toInt()}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          ],
        ),
      ),
    );

    // Page 8: Payment History
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Payment History Log', primaryColor),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Receipt No', 'Student', 'Mode', 'Amount', 'Status'],
              data: report.paymentHistory
                  .take(15)
                  .map(
                    (p) => [
                      p.receiptNo,
                      p.studentName,
                      p.mode,
                      '₹${p.amount.toInt()}',
                      p.status,
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          ],
        ),
      ),
    );

    // Last Page: Sign-off & Footer
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Spacer(),
            pw.Text(
              'Report Summary Completed',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'This document is an automatically generated official business performance report.',
              style: pw.TextStyle(fontSize: 11, color: greyColor),
            ),
            pw.SizedBox(height: 30),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Text(
              'Powered by StudyDesk Business Analytics Suite',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: darkColor,
              ),
            ),
            pw.Text(
              'Generated Date: ${report.generatedDate}',
              style: pw.TextStyle(fontSize: 9, color: greyColor),
            ),
            pw.Spacer(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPageHeader(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: color, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildMetricBox(String title, String value, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(4),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F9FA'),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
