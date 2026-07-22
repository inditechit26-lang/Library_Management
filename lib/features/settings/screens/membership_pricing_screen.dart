import 'package:flutter/material.dart';
import '../widgets/membership_pricing_settings.dart';

class MembershipPricingScreen extends StatelessWidget {
  const MembershipPricingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Membership Pricing')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      children: [
        Text(
          'Configure membership plans',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Set prices and promotional badges for full-time and half-time memberships.',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        const MembershipPricingSettings(),
      ],
    ),
  );
}
