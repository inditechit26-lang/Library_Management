import 'package:flutter/material.dart';

class AdmissionHeader extends StatelessWidget {
  final VoidCallback onCancel;
  const AdmissionHeader({super.key, required this.onCancel});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Admission',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Register a new student',
                style: TextStyle(fontSize: 10, color: Color(0xFF9297A8)),
              ),
            ],
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
      ],
    ),
  );
}

class AdmissionProgress extends StatelessWidget {
  final int step;
  final List<String> labels;
  const AdmissionProgress({
    super.key,
    required this.step,
    required this.labels,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
    child: Column(
      children: [
        Row(
          children: List.generate(
            labels.length,
            (index) => Expanded(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: index <= step
                          ? const Color(0xFF5650C7)
                          : const Color(0xFFF0F1F5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: index < step
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: index == step
                                    ? Colors.white
                                    : const Color(0xFF9BA0AF),
                              ),
                            ),
                    ),
                  ),
                  if (index < labels.length - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 2,
                        color: index < step
                            ? const Color(0xFF5650C7)
                            : const Color(0xFFE6E8EF),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            labels[step],
            key: ValueKey(step),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF777D8E),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class AdmissionNavigation extends StatelessWidget {
  final int step;
  final bool canContinue;
  final VoidCallback onBack, onNext;
  const AdmissionNavigation({
    super.key,
    required this.step,
    required this.canContinue,
    required this.onBack,
    required this.onNext,
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAF1))),
      ),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ),
          if (step > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: canContinue ? onNext : null,
              child: Text(step == 4 ? 'Confirm Admission' : 'Continue'),
            ),
          ),
        ],
      ),
    ),
  );
}
