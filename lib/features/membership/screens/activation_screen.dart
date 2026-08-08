import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/membership_provider.dart';
import '../repositories/activation_code_repository.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({
    super.key,
    required this.libraryName,
    required this.onActivated,
    this.onBack,
  });

  final String libraryName;
  final VoidCallback onActivated;
  final VoidCallback? onBack;

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final code = _controller.text.trim();
    if (code.length != 8) {
      await _showError(
        'Invalid Activation Code',
        'Enter the complete 8-character code provided by the administrator.',
      );
      return;
    }
    final success = await ref
        .read(membershipActionProvider.notifier)
        .activate(code: code, libraryName: widget.libraryName);
    if (!mounted) return;
    if (!success) {
      final error = ref.read(membershipActionProvider).error;
      if (error is ActivationException) {
        switch (error.failure) {
          case ActivationFailure.invalid:
            await _showError(
              'Invalid Activation Code',
              'This code does not exist. Check the code and try again.',
            );
          case ActivationFailure.alreadyUsed:
            await _showError(
              'Activation Code Already Used',
              'This code has already been assigned to another membership.',
            );
          case ActivationFailure.suspended:
            await _showError(
              'Activation Code Unavailable',
              'This code is not available for activation. Contact support.',
            );
        }
      } else {
        await _showError(
          'Unable to Activate Membership',
          'Check your internet connection and try again.',
        );
      }
      return;
    }
    widget.onActivated();
  }

  Future<void> _showError(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.error_outline_rounded),
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
    final loading = ref.watch(membershipActionProvider).isLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          const SizedBox(height: 24),
          Icon(Icons.verified_user_outlined, size: 56, color: colors.primary),
          const SizedBox(height: 20),
          Text(
            'Activate Membership',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the license code provided by the administrator.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              labelText: 'Activation Code',
              hintText: 'SH4K8P2Q',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: loading ? null : _activate,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_rounded),
            label: const Text('Activate Membership'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
