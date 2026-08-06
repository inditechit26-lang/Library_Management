import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../membership/models/subscription_model.dart';
import '../../membership/providers/membership_provider.dart';
import '../../membership/screens/activation_screen.dart';
import '../../membership/screens/purchase_membership_screen.dart';

enum _GatePage { overview, trialForm, purchase, activation }

class SubscriptionGateScreen extends ConsumerStatefulWidget {
  const SubscriptionGateScreen({
    super.key,
    required this.subscription,
    this.requiredGate = true,
    this.openPurchase = false,
    this.fallbackLibraryName = '',
  });

  final SubscriptionModel subscription;
  final bool requiredGate;
  final bool openPurchase;
  final String fallbackLibraryName;

  @override
  ConsumerState<SubscriptionGateScreen> createState() =>
      _SubscriptionGateScreenState();
}

class _SubscriptionGateScreenState
    extends ConsumerState<SubscriptionGateScreen> {
  late _GatePage _page;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _owner;
  late final TextEditingController _library;
  late final TextEditingController _mobile;
  late final TextEditingController _city;
  late final TextEditingController _capacity;

  @override
  void initState() {
    super.initState();
    _page = widget.openPurchase ? _GatePage.purchase : _GatePage.overview;
    final value = widget.subscription;
    _owner = TextEditingController(text: value.ownerName);
    _library = TextEditingController(text: value.libraryName);
    _mobile = TextEditingController(text: value.mobile);
    _city = TextEditingController(text: value.city);
    _capacity = TextEditingController(
      text: value.seatCapacity?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _owner.dispose();
    _library.dispose();
    _mobile.dispose();
    _city.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _submitTrial() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(membershipActionProvider.notifier)
        .startTrial(
          ownerName: _owner.text,
          libraryName: _library.text,
          mobile: _mobile.text,
          city: _city.text,
          seatCapacity: int.tryParse(_capacity.text),
        );
    if (!mounted) return;
    if (!success) {
      await _error(
        'Unable to Start Trial',
        'Check your internet connection and try again.',
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Trial Started Successfully — Enjoy your 7-day free trial.',
        ),
      ),
    );
    if (!widget.requiredGate) Navigator.of(context).pop();
  }

  Future<void> _activated() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.workspace_premium_rounded, size: 48),
        title: const Text('Membership Activated Successfully'),
        content: const Text(
          'StudyHall Pro is now active. You can continue using all premium features.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Start Using App'),
          ),
        ],
      ),
    );
    if (mounted && !widget.requiredGate) Navigator.of(context).pop();
  }

  Future<void> _error(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.cloud_off_outlined),
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Try Again'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !widget.requiredGate,
      child: Material(
        color: colors.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'STUDYHALL PRO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.requiredGate)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: switch (_page) {
                    _GatePage.overview => _overview(),
                    _GatePage.trialForm => _trialForm(),
                    _GatePage.purchase => PurchaseMembershipScreen(
                      key: const ValueKey('purchase'),
                      onBack: () => setState(() => _page = _GatePage.overview),
                      onEnterCode: () =>
                          setState(() => _page = _GatePage.activation),
                    ),
                    _GatePage.activation => ActivationScreen(
                      key: const ValueKey('activation'),
                      libraryName: _library.text.isNotEmpty
                          ? _library.text
                          : widget.subscription.libraryName.isNotEmpty
                          ? widget.subscription.libraryName
                          : widget.fallbackLibraryName,
                      onBack: () => setState(() => _page = _GatePage.overview),
                      onActivated: _activated,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overview() {
    final expired =
        widget.subscription.effectiveStatus == MembershipStatus.expired;
    final suspended =
        widget.subscription.effectiveStatus == MembershipStatus.suspended;
    final colors = Theme.of(context).colorScheme;
    final title = suspended
        ? 'Membership Suspended'
        : expired
        ? widget.subscription.plan == 'Trial'
              ? 'Your Free Trial Has Ended'
              : 'Your Membership Has Expired'
        : 'Welcome to StudyHall Pro';
    final subtitle = suspended
        ? 'Contact support to restore access to your membership.'
        : expired
        ? 'Purchase a membership to continue using all premium features.'
        : 'Start your free 7-day trial and experience all premium features.';

    return SingleChildScrollView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              expired ? Icons.lock_clock_outlined : Icons.stars_rounded,
              size: 44,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 36),
          if (!expired && !suspended)
            FilledButton.icon(
              onPressed: () => setState(() => _page = _GatePage.trialForm),
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Start 7 Days Free Trial'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            )
          else
            FilledButton.icon(
              onPressed: () => setState(() => _page = _GatePage.purchase),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Purchase Membership'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _page = _GatePage.activation),
            icon: const Icon(Icons.key_rounded),
            label: const Text('Already Purchased?  Enter Activation Code'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trialForm() {
    final loading = ref.watch(membershipActionProvider).isLoading;
    return Form(
      key: _formKey,
      child: ListView(
        key: const ValueKey('trial-form'),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => setState(() => _page = _GatePage.overview),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Text(
            'Tell us about your library',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text('A few details to personalize your 7-day trial.'),
          const SizedBox(height: 24),
          _field(
            _owner,
            'Owner Name',
            Icons.person_outline_rounded,
            required: true,
          ),
          _field(
            _library,
            'Library Name',
            Icons.local_library_outlined,
            required: true,
          ),
          _field(
            _mobile,
            'Mobile Number',
            Icons.phone_outlined,
            required: true,
            keyboard: TextInputType.phone,
            validator: (value) => RegExp(r'^\d{10}$').hasMatch(value)
                ? null
                : 'Enter a valid 10-digit mobile number',
          ),
          _field(_city, 'City (Optional)', Icons.location_city_outlined),
          _field(
            _capacity,
            'Seat Capacity (Optional)',
            Icons.event_seat_outlined,
            keyboard: TextInputType.number,
            validator: (value) =>
                value.isEmpty || (int.tryParse(value) ?? 0) > 0
                ? null
                : 'Enter a valid seat capacity',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: loading ? null : _submitTrial,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Start My Free Trial'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboard,
    String? Function(String value)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return '$label is required';
        return validator?.call(text);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
