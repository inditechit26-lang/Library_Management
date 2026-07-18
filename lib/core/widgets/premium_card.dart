import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E9EF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A292C47),
              blurRadius: 28,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
