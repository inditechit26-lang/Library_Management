import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PurchaseMembershipScreen extends StatelessWidget {
  const PurchaseMembershipScreen({
    super.key,
    required this.onEnterCode,
    this.onBack,
  });

  final VoidCallback onEnterCode;
  final VoidCallback? onBack;
  static const upiId = '9527782347@ibl';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const features = [
      'Unlimited Students',
      'Unlimited Seats',
      'Reports & Receipts',
      'Dashboard',
      'Multi Library',
      'Regular Updates',
      'Premium Support',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          Text(
            'StudyHall Pro Standard',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '₹499 / Year',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features
                .map(
                  (item) => Chip(
                    avatar: const Icon(Icons.check_rounded, size: 16),
                    label: Text(item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: colors.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colors.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: QrImageView(
                      data: 'upi://pay?pa=$upiId&pn=IndiTech&cu=INR&am=499',
                      size: 150,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('UPI ID'),
                    subtitle: const Text(upiId),
                    trailing: IconButton(
                      tooltip: 'Copy UPI ID',
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: upiId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('UPI ID copied')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.account_balance_outlined),
                    title: Text('Bank Details'),
                    subtitle: Text(
                      'Contact IndiTech Support for NEFT/IMPS bank details.',
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Complete the payment and share the receipt with support. '
                    'Your administrator will provide an 8-character activation code.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onEnterCode,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text("I've Completed Payment"),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onEnterCode,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Enter Activation Code'),
          ),
        ],
      ),
    );
  }
}
