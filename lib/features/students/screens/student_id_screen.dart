import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_id_service.dart';
import '../widgets/student_identity_cards.dart';

class StudentIdScreen extends StatefulWidget {
  final Student student;
  const StudentIdScreen({super.key, required this.student});
  @override
  State<StudentIdScreen> createState() => _StudentIdScreenState();
}

class _StudentIdScreenState extends State<StudentIdScreen> {
  int revision = 0;
  bool working = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Digital Student ID'),
      actions: [
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Hero(
                      tag: 'student-id-${widget.student.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: AspectRatio(
                          aspectRatio: 1.58,
                          child: StudentIdCard(
                            student: widget.student,
                            revision: revision,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Color(0xFF24845F),
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Verified digital identity',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF727788),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _Actions(
            working: working,
            onDownload: () => _run(
              () =>
                  StudentIdService.download(widget.student, revision: revision),
              'PDF saved',
            ),
            onPrint: () => _run(
              () => StudentIdService.printCard(
                widget.student,
                revision: revision,
              ),
            ),
            onShare: () => _run(
              () => StudentIdService.share(widget.student, revision: revision),
            ),
            onRegenerate: _regenerate,
            onClose: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );

  Future<void> _run(Future<void> Function() action, [String? message]) async {
    if (working) return;
    setState(() => working = true);
    try {
      await action();
      if (message != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  void _regenerate() {
    setState(() => revision++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Digital ID regenerated successfully')),
    );
  }
}

class _Actions extends StatelessWidget {
  final bool working;
  final VoidCallback onDownload, onPrint, onShare, onRegenerate, onClose;
  const _Actions({
    required this.working,
    required this.onDownload,
    required this.onPrint,
    required this.onShare,
    required this.onRegenerate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      16,
      14,
      16,
      MediaQuery.paddingOf(context).bottom + 12,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFE5E7ED))),
      boxShadow: [
        BoxShadow(
          color: Color(0x0C20243B),
          blurRadius: 20,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _Action(
                icon: Icons.download_outlined,
                label: 'Download PDF',
                onTap: working ? null : onDownload,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Action(
                icon: Icons.print_outlined,
                label: 'Print',
                onTap: working ? null : onPrint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Action(
                icon: Icons.ios_share_outlined,
                label: 'Share PDF',
                onTap: working ? null : onShare,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: working ? null : onRegenerate,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Regenerate'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: FilledButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      padding: const EdgeInsets.symmetric(horizontal: 5),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
