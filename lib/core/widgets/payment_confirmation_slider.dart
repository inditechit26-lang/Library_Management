import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentConfirmationSlider extends StatefulWidget {
  final VoidCallback onConfirmed;
  final bool enabled;
  const PaymentConfirmationSlider({
    super.key,
    required this.onConfirmed,
    this.enabled = true,
  });

  @override
  State<PaymentConfirmationSlider> createState() =>
      _PaymentConfirmationSliderState();
}

class _PaymentConfirmationSliderState extends State<PaymentConfirmationSlider> {
  double progress = 0;
  bool dragging = false;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const height = 64.0, thumb = 52.0, inset = 6.0;
      final travel = constraints.maxWidth - thumb - inset * 2;
      return Semantics(
        button: true,
        enabled: widget.enabled,
        label: 'Slide to confirm payment received',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: widget.enabled
              ? (_) {
                  HapticFeedback.selectionClick();
                  setState(() => dragging = true);
                }
              : null,
          onHorizontalDragUpdate: widget.enabled
              ? (details) => setState(() {
                  progress = (progress + details.delta.dx / travel).clamp(0, 1);
                })
              : null,
          onHorizontalDragEnd: widget.enabled ? (_) => _finish() : null,
          onHorizontalDragCancel: widget.enabled ? _reset : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FA),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: dragging
                    ? const Color(0xFFBDB8ED)
                    : const Color(0xFFE1E2E8),
                width: dragging ? 1.4 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D1F2340),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: inset,
                  top: inset,
                  bottom: inset,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: dragging ? 0 : 260),
                    curve: Curves.easeOutCubic,
                    width: thumb + travel * progress,
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? const Color(0xFFE8E6FA)
                          : const Color(0xFFECEEF2),
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
                Positioned(
                  left: thumb + 20,
                  right: 14,
                  child: AnimatedOpacity(
                    opacity: (1 - progress * 1.25).clamp(0, 1),
                    duration: const Duration(milliseconds: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 15,
                          color: widget.enabled
                              ? const Color(0xFF85899A)
                              : const Color(0xFFB4B7C0),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          widget.enabled
                              ? 'Confirm payment received'
                              : 'Complete payment details first',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: widget.enabled
                                ? const Color(0xFF666B7C)
                                : const Color(0xFFA2A5AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: inset + travel * progress,
                  top: inset,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: dragging ? 0 : 280),
                    curve: Curves.easeOutCubic,
                    width: thumb,
                    height: thumb,
                    decoration: BoxDecoration(
                      color: !widget.enabled
                          ? const Color(0xFFB9BCC5)
                          : progress >= .82
                          ? const Color(0xFF24845F)
                          : const Color(0xFF5145C8),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x305145C8),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      progress >= .82
                          ? Icons.check_rounded
                          : Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  void _finish() {
    if (progress >= .82) {
      HapticFeedback.mediumImpact();
      setState(() {
        progress = 1;
        dragging = false;
      });
      widget.onConfirmed();
    } else {
      HapticFeedback.selectionClick();
      _reset();
    }
  }

  void _reset() => setState(() {
    progress = 0;
    dragging = false;
  });
}
