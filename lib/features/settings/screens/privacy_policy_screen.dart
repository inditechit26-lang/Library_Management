import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy & Security Policy',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Policy Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2438), const Color(0xFF161A29)]
                      : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                ),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E3752)
                      : const Color(0xFFC7D2FE),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF10B981),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Privacy & Protection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your library data is encrypted and private. Last Updated: July 2026',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _PolicySectionCard(
              number: '01',
              title: 'Information We Collect',
              content:
                  'StudyDesk collects information provided directly during registration and library operation. This includes owner account profile (name, phone number, email), library branch setup, member records (student names, contact numbers, emergency contacts, seat allocations, and payment transaction logs).',
            ),
            const SizedBox(height: 14),
            _PolicySectionCard(
              number: '02',
              title: 'Purpose & Usage of Data',
              content:
                  'Collected operational data is exclusively used to deliver library management features. This includes seat map tracking, payment status calculation, generation of fee receipts, analytical reports, and user-triggered WhatsApp reminder dispatching.',
            ),
            const SizedBox(height: 14),
            _PolicySectionCard(
              number: '03',
              title: 'Security & Encryption Safeguards',
              content:
                  'We employ industry-standard encryption protocol and cloud access controls to safeguard member and financial data against unauthorized access, loss, or alteration.',
            ),
            const SizedBox(height: 14),
            _PolicySectionCard(
              number: '04',
              title: 'Third-Party Integration & Sharing Policy',
              content:
                  'We strictly do NOT sell, rent, or monetize your library or member data. Data is shared exclusively with essential platform integrators (such as Firebase for cloud authentication and storage) solely to deliver core services.',
            ),
            const SizedBox(height: 14),
            _PolicySectionCard(
              number: '05',
              title: 'Data Control & Owner Rights',
              content:
                  'Library owners maintain total ownership over their records. You can update owner credentials, member details, or request account data purge at any time by contacting our support desk.',
            ),
            const SizedBox(height: 14),
            _PolicySectionCard(
              number: '06',
              title: 'Contact Us Regarding Privacy',
              content:
                  'For questions or privacy concerns, contact our support team directly via WhatsApp support in Settings or email us at inditechit26@gmail.com.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _PolicySectionCard({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
