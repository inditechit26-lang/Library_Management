import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SubscriptionGateScreen extends StatefulWidget {
  const SubscriptionGateScreen({super.key});

  @override
  State<SubscriptionGateScreen> createState() => _SubscriptionGateScreenState();
}

class _SubscriptionGateScreenState extends State<SubscriptionGateScreen> {
  final _codeController = TextEditingController();
  bool _purchase = false;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startTrial() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (mounted) context.go('/app');
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _redeemCode() async {
    setState(() => _loading = true);
    if (_codeController.text.trim().isEmpty) {
      _show('Enter the activation code provided by IndiTech.');
      setState(() => _loading = false);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _show('Code submitted. IndiTech will confirm activation manually.');
    if (mounted) setState(() => _loading = false);
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: _purchase
                      ? _purchaseView(colors)
                      : _welcomeView(colors),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeView(ColorScheme colors) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 38,
        backgroundColor: colors.primaryContainer,
        child: Icon(
          Icons.local_library_rounded,
          size: 42,
          color: colors.primary,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'StudyHub',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      Text(
        'Choose how you would like to access your library workspace.',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
      const SizedBox(height: 28),
      FilledButton.icon(
        onPressed: _loading ? null : _startTrial,
        icon: const Icon(Icons.timer_outlined),
        label: const Text('Start 7-Day Free Trial'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _loading ? null : () => setState(() => _purchase = true),
        icon: const Icon(Icons.workspace_premium_outlined),
        label: const Text('Purchase Full Plan Â· 1 Year'),
      ),
    ],
  );

  Widget _purchaseView(ColorScheme colors) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextButton.icon(
        onPressed: () => setState(() => _purchase = false),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
      ),
      Text(
        'Purchase StudyHub',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      const Text(
        'Pay using the QR code, then contact the IndiTech team for manual confirmation and your one-time activation code.',
      ),
      const SizedBox(height: 20),
      Center(
        child: QrImageView(
          data: 'upi://pay?pa=9527782347@ibl&pn=IndiTech&cu=INR',
          size: 190,
        ),
      ),
      const SizedBox(height: 12),
      const Center(
        child: SelectableText(
          'UPI: 9527782347@ibl',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 20),
      const ListTile(
        leading: Icon(Icons.phone_outlined),
        title: Text('IndiTech Support'),
        subtitle: Text('+91 95277 82347'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _codeController,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Activation code',
          hintText: 'Enter the code from IndiTech',
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _loading ? null : _redeemCode,
        child: const Text('Activate Full Plan'),
      ),
    ],
  );
}
