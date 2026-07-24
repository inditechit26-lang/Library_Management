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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D20243B),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x05FFFFFF),
                blurRadius: 1,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
