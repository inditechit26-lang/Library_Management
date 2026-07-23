import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for StudyDesk',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last Updated: July 2026',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '1. Information We Collect'),
            _SectionBody(
              text:
                  'We collect information provided directly by library owners and members, including owner account details (name, contact number, branch details), student profile information (name, phone number, seat assignments, subscription plans), and attendance records.',
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '2. How We Use Your Information'),
            _SectionBody(
              text:
                  'The collected data is strictly utilized to operate and improve the StudyDesk library management service. This includes managing seat availability, fee tracking, sending notification alerts/reminders, and generating business analytics for library administration.',
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '3. Data Protection & Security'),
            _SectionBody(
              text:
                  'We prioritize the security of your data. We implement industry-standard administrative, physical, and technical safeguards to keep personal and operational data safe from unauthorized access, loss, or disclosure.',
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '4. Third-Party Services & Sharing'),
            _SectionBody(
              text:
                  'StudyDesk does not sell, rent, or trade personal data to third parties. Data is shared only with essential service integrators (e.g., communication channels like WhatsApp for user-triggered reminders) solely for providing requested features.',
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '5. Your Data Rights & Control'),
            _SectionBody(
              text:
                  'Library owners and members have full control over their account data. You can access, update, export, or request deletion of personal information stored in StudyDesk at any time through the app settings or by contacting our support team.',
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '6. Changes to This Policy'),
            _SectionBody(
              text:
                  'We may update our Privacy Policy periodically to reflect app updates or regulatory changes. We encourage users to review this page occasionally to remain informed about how we protect their data.',
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '7. Contact Us'),
            _SectionBody(
              text:
                  'If you have any questions or concerns regarding this Privacy Policy, please contact us via WhatsApp Support (+91 9527782347) or through the support channels available in StudyDesk Settings.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
