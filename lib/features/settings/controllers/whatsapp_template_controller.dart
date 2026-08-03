import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/backend_providers.dart';
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

class WhatsAppTemplateNotifier extends Notifier<String> {
  @override
  String build() {
    final data = ref.watch(templateProvider).value;
    final saved = data?['membershipRenewal'] as String?;
    return saved?.trim().isNotEmpty == true ? saved! : kDefaultRenewalTemplate;
  }

  Future<void> updateTemplate(String newTemplate) async {
    state = newTemplate;
    await ref.read(templateRepositoryProvider).updateTemplates({
      'membershipRenewal': newTemplate,
    });
  }

  Future<void> resetToDefault() async {
    state = kDefaultRenewalTemplate;
    await ref.read(templateRepositoryProvider).updateTemplates({
      'membershipRenewal': kDefaultRenewalTemplate,
    });
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
