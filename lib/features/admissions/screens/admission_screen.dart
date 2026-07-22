import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../seats/controllers/seats_controller.dart';
import '../../settings/controllers/pricing_controller.dart';
import '../../settings/models/pricing_settings.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/models/student.dart';
import '../controllers/admission_controller.dart';
import '../widgets/document_upload_card.dart';
import '../widgets/admission_scaffold.dart';
import '../widgets/membership_selector.dart';
import '../widgets/membership_summary.dart';
import '../widgets/pricing_selector.dart';
import '../widgets/custom_plan_card.dart';
import '../widgets/payment_qr_card.dart';
import '../widgets/payment_summary.dart';
import '../widgets/review_card.dart';
import '../widgets/seat_selector.dart';
import '../widgets/student_information_card.dart';
import '../widgets/success_screen.dart';

class AdmissionScreen extends ConsumerStatefulWidget {
  const AdmissionScreen({super.key});
  @override
  ConsumerState<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends ConsumerState<AdmissionScreen> {
  late final AdmissionController admission;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final emergency = TextEditingController();
  final notes = TextEditingController();
  Student? created;
  static const titles = [
    'Student Information',
    'Membership',
    'Seat',
    'Payment',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    admission = AdmissionController(ref.read(pricingProvider));
    admission.addListener(_refresh);
  }

  @override
  void dispose() {
    admission.removeListener(_refresh);
    admission.dispose();
    name.dispose();
    phone.dispose();
    emergency.dispose();
    notes.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    admission.updatePricing(ref.watch(pricingProvider));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .94,
      child: admission.completed && created != null ? _success() : _workflow(),
    );
  }

  Widget _workflow() => Column(
    children: [
      AdmissionHeader(onCancel: () => Navigator.pop(context)),
      AdmissionProgress(step: admission.step, labels: titles),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(.035, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: SingleChildScrollView(
            key: ValueKey(admission.step),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: _step(),
          ),
        ),
      ),
      AdmissionNavigation(
        step: admission.step,
        canContinue: _canContinue,
        onBack: admission.back,
        onNext: _next,
      ),
    ],
  );

  Widget _step() => switch (admission.step) {
    0 => Column(
      children: [
        StudentInformationCard(
          formKey: formKey,
          name: name,
          phone: phone,
          emergency: emergency,
          notes: notes,
        ),
        const SizedBox(height: 14),
        DocumentUploadCard(
          uploaded: admission.documents,
          onToggle: admission.toggleDocument,
        ),
      ],
    ),
    1 => _membershipStep(),
    2 => AdmissionSeatSelector(
      membership: admission.membership,
      seats: ref.watch(seatsProvider),
      selected: admission.selectedSeat,
      onSelected: admission.chooseSeat,
      studentName: name.text.trim(),
    ),
    3 => Column(
      children: [
        AdmissionPaymentSummary(
          membership: _membership,
          joining: admission.joiningDisplay,
          expiry: admission.expiryDisplay,
          fee: admission.fee,
        ),
        const SizedBox(height: 14),
        AdmissionPaymentQrCard(
          amount: admission.fee,
          confirmed: admission.paymentConfirmed,
          onConfirmed: admission.setPaymentConfirmed,
        ),
      ],
    ),
    _ => AdmissionReviewCard(
      student: name.text.trim(),
      membership: _membership,
      seat: _seat,
      fee: admission.fee,
      joining: admission.joiningDisplay,
      expiry: admission.expiryDisplay,
      payment: admission.paymentConfirmed ? 'Paid' : 'Pending',
    ),
  };

  Widget _membershipStep() {
    final pricing = admission.pricing;
    final content = Column(
      children: [
        MembershipSelector(
          selected: admission.membership,
          fullTimeMonthly: pricing.fullTime.monthly,
          halfTimeMonthly: pricing.halfTime.monthly,
          onChanged: admission.chooseMembership,
        ),
        const SizedBox(height: 22),
        PricingSelector(
          selected: admission.period,
          pricing: pricing.forMembership(admission.membership),
          onChanged: admission.choosePeriod,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: admission.period == MembershipPeriod.custom
              ? Padding(
                  key: const ValueKey(true),
                  padding: const EdgeInsets.only(top: 14),
                  child: CustomPlanCard(
                    start: admission.customStart,
                    end: admission.customEnd,
                    days: admission.customEnd == null
                        ? null
                        : admission.totalDays,
                    amount: admission.customEnd == null ? null : admission.fee,
                    onStart: admission.setCustomStart,
                    onEnd: admission.setCustomEnd,
                    onDays: admission.setCustomDays,
                    onAmount: admission.setCustomAmount,
                  ),
                )
              : const SizedBox(key: ValueKey(false)),
        ),
      ],
    );
    final summary = MembershipSummary(
      plan: admission.period?.label ?? '',
      membership: _membership,
      joining: admission.joiningDisplay,
      expiry: admission.period == null ? '' : admission.expiryDisplay,
      duration: admission.duration,
      seat: _seat,
      amount: admission.fee,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: content),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: summary),
            ],
          );
        }
        return Column(children: [content, const SizedBox(height: 16), summary]);
      },
    );
  }

  bool get _canContinue => switch (admission.step) {
    1 => admission.pricingValid,
    2 =>
      admission.membership == MembershipType.halfTime ||
          admission.selectedSeat != null,
    _ => true,
  };
  String get _membership => admission.membership == MembershipType.fullTime
      ? 'Full Time'
      : 'Half Time';
  String get _seat => admission.membership == MembershipType.fullTime
      ? admission.selectedSeat ?? ''
      : 'Flexible Seating';

  void _next() {
    if (admission.step == 0 && !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_canContinue) return;
    if (admission.step < 4) {
      admission.next();
      return;
    }
    final students = ref.read(studentsProvider);
    created = admission.create(
      id: students.length + 1,
      name: name.text,
      phone: phone.text,
      emergencyContact: emergency.text,
      notes: notes.text,
    );
    ref.read(studentsProvider.notifier).add(created!);
    if (admission.membership == MembershipType.fullTime &&
        admission.selectedSeat != null) {
      final seat = ref
          .read(seatsProvider)
          .firstWhere((item) => item.seatLabel == admission.selectedSeat);
      created = created!.copyWith(seatId: seat.seatId);
      ref.read(studentsProvider.notifier).update(created!);
      ref.read(seatsProvider.notifier).assign(seat.seatId, created!.id);
    }
  }

  Widget _success() {
    final receipt =
        'SR-${DateTime.now().year}-${created!.id.toString().padLeft(4, '0')}';
    return AdmissionSuccessScreen(
      student: created!.name,
      seat: _seat,
      receipt: receipt,
      membership: _membership,
      expiry: admission.expiryDisplay,
      onProfile: () {
        Navigator.pop(context);
        context.push('/students/${created!.id}');
      },
      onPrint: () {},
      onShare: () => SharePlus.instance.share(
        ShareParams(text: '$receipt ${created!.name}'),
      ),
      onDone: () => Navigator.pop(context),
    );
  }
}
