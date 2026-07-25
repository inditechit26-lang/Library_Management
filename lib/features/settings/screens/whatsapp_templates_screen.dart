import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/owner_profile_controller.dart';
import '../controllers/whatsapp_template_controller.dart';

class WhatsappTemplatesScreen extends ConsumerStatefulWidget {
  const WhatsappTemplatesScreen({super.key});

  @override
  ConsumerState<WhatsappTemplatesScreen> createState() =>
      _WhatsappTemplatesScreenState();
}

class _WhatsappTemplatesScreenState
    extends ConsumerState<WhatsappTemplatesScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final template = ref.watch(whatsappTemplateProvider);
    final ownerProfile = ref.watch(ownerProfileProvider);
    final colors = Theme.of(context).colorScheme;

    // Keep text controller synchronized with state if not actively focused/edited
    if (_controller.text != template && !FocusScope.of(context).hasFocus) {
      _controller.text = template;
    }

    // Generate live sample preview using dummy student values & owner library name
    final samplePreview = WhatsAppTemplateNotifier.formatMessage(
      template: _controller.text.isEmpty ? template : _controller.text,
      libraryName: ownerProfile.libraryName.isNotEmpty
          ? ownerProfile.libraryName
          : 'StudyDesk Library',
      studentName: 'Rahul Sharma',
      seatNumber: 'A-12',
      planName: 'Full Day (Full Time)',
      amount: '1200',
      expiryDate: '30 Oct 2026',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp Templates',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to Default',
            icon: const Icon(Icons.restore),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Available Placeholders',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      '{LibraryName}',
                      '{StudentName}',
                      '{SeatNumber}',
                      '{PlanName}',
                      '{Amount}',
                      '{ExpiryDate}',
                    ]
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: colors.primary,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Template Editor Title
            Text(
              'Membership Renewal Reminder Template',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),

            // Editor Textfield
            TextField(
              controller: _controller,
              maxLines: 12,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Enter template text...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
                fillColor: colors.surfaceContainerLowest,
                filled: true,
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),

            // Action Buttons (Save / Reset)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmReset(context),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset Default'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(whatsappTemplateProvider.notifier)
                          .updateTemplate(_controller.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'WhatsApp template updated successfully!',
                            ),
                            backgroundColor: colors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Template'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Live Preview Header
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Color(0xFF25D366),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live WhatsApp Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Simulated WhatsApp Chat Bubble Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5DDD5), // Authentic WhatsApp Chat BG
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SelectableText(
                        samplePreview,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: samplePreview));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preview copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Preview'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () => _testSendWhatsApp(samplePreview),
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
                        label: const Text('Test Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Template?'),
        content: const Text(
          'This will revert the Membership Renewal Reminder template back to the standard default format.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(whatsappTemplateProvider.notifier)
                  .resetToDefault();
              _controller.text = kDefaultRenewalTemplate;
              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset to default template'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _testSendWhatsApp(String message) async {
    final encodedMsg = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/?text=$encodedMsg');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch WhatsApp'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
