import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../students/models/student.dart';
import 'owner_profile_controller.dart';

const String kDefaultRenewalTemplate = '''
━━━━━━━━━━━━━━━━━━━━━━

📚 *{LibraryName}*

Hello *{StudentName}*,

Your library membership is due for renewal.

• Seat: {SeatNumber}
• Plan: {PlanName}
• Renewal Fee: ₹{Amount}
• Expiry Date: {ExpiryDate}

Please renew your membership to continue enjoying uninterrupted access to the library.

Thank you.

*{LibraryName}*

━━━━━━━━━━━━━━━━━━━━━━''';

const String _kTemplatePrefKey = 'whatsapp_membership_renewal_template';

class WhatsAppTemplateNotifier extends Notifier<String> {
  @override
  String build() {
    _loadFromPrefs();
    return kDefaultRenewalTemplate;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kTemplatePrefKey);
      if (saved != null && saved.trim().isNotEmpty) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> updateTemplate(String newTemplate) async {
    state = newTemplate;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTemplatePrefKey, newTemplate);
    } catch (_) {}
  }

  Future<void> resetToDefault() async {
    state = kDefaultRenewalTemplate;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kTemplatePrefKey);
    } catch (_) {}
  }

  /// Formats the template with actual values for student and library name.
  static String formatMessage({
    required String template,
    required String libraryName,
    required String studentName,
    required String seatNumber,
    required String planName,
    required String amount,
    required String expiryDate,
  }) {
    return template
        .replaceAll('{LibraryName}', libraryName)
        .replaceAll('{StudentName}', studentName)
        .replaceAll('{SeatNumber}', seatNumber)
        .replaceAll('{PlanName}', planName)
        .replaceAll('{Amount}', amount)
        .replaceAll('{ExpiryDate}', expiryDate);
  }

  /// Convenience helper to format message directly from a Student object & OwnerProfile.
  static String buildStudentRenewalMessage({
    required String template,
    required Student student,
    required OwnerProfile ownerProfile,
  }) {
    final planName = student.membership == MembershipType.fullTime
        ? 'Full Day (Full Time)'
        : 'Half Day (Half Time)';
    
    // Format fee amount nicely (remove trailing .0 if integer)
    final feeStr = student.fee % 1 == 0
        ? student.fee.toInt().toString()
        : student.fee.toStringAsFixed(2);

    final libraryName = ownerProfile.libraryName.isNotEmpty
        ? ownerProfile.libraryName
        : 'StudyDesk Library';

    return formatMessage(
      template: template,
      libraryName: libraryName,
      studentName: student.name,
      seatNumber: student.seat.isNotEmpty ? student.seat : 'N/A',
      planName: planName,
      amount: feeStr,
      expiryDate: student.expiry,
    );
  }
}

final whatsappTemplateProvider =
    NotifierProvider<WhatsAppTemplateNotifier, String>(
  WhatsAppTemplateNotifier.new,
);
