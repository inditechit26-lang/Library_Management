import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../receipts/models/receipt_model.dart';
import '../../receipts/screens/receipt_pdf_viewer_screen.dart';
import '../../seats/controllers/seats_controller.dart' as sc;
import '../../settings/controllers/pricing_controller.dart';
import '../../settings/models/pricing_settings.dart';
import '../../settings/controllers/library_configuration_controller.dart';
import '../../settings/models/library_configuration.dart';
import '../../students/models/student.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
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
  final String? initialSeat;
  const AdmissionScreen({super.key, this.initialSeat});
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
  bool _isSubmitting = false;
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
    if (widget.initialSeat != null) {
      admission.selectedSeat = widget.initialSeat;
    }
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
    final configuration = ref.watch(libraryConfigurationProvider);
    admission.selectedSectionId ??= configuration.enabledSections.isEmpty
        ? null
        : configuration.enabledSections.first.id;
    if (!configuration.seatTypes.contains(admission.selectedSeatType)) {
      admission.selectedSeatType = configuration.seatTypes.first;
      admission.membership =
          admission.selectedSeatType == LibrarySeatType.fullTimeReserved
          ? MembershipType.fullTime
          : MembershipType.halfTime;
    }
    final fullTimePricing = configuration.pricingForSection(
      admission.selectedSectionId,
      isFullTime: true,
    );
    final halfTimePricing = configuration.pricingForSection(
      admission.selectedSectionId,
      isFullTime: false,
    );
    final shifts = ref.watch(pricingProvider).halfTimeShifts;
    admission.customDefaultPrice = configuration.priceFor(
      MembershipPeriod.custom,
      sectionId: admission.selectedSectionId,
      isFullTime: admission.membership == MembershipType.fullTime,
    );
    admission.updatePricing(
      PricingSettings(
        fullTimeAc: fullTimePricing,
        halfTimeAc: halfTimePricing,
        fullTimeNonAc: fullTimePricing,
        halfTimeNonAc: halfTimePricing,
        halfTimeShifts: shifts,
      ),
    );
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
        canContinue: _canContinue && !_isSubmitting,
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
        if (ref
            .watch(libraryConfigurationProvider)
            .requiredDocuments
            .isNotEmpty)
          DocumentUploadCard(
            uploaded: admission.documents,
            requirements: ref
                .watch(libraryConfigurationProvider)
                .requiredDocuments,
            onToggle: admission.toggleDocument,
          ),
      ],
    ),
    1 => _membershipStep(),
    2 => AdmissionSeatSelector(
      category: admission.category,
      membership: admission.membership,
      seats: ref.watch(sc.seatsProvider),
      selected: admission.selectedSeat,
      selectedShift: admission.selectedHalfTimeShift,
      onSelected: admission.chooseSeat,
      studentName: name.text.trim(),
      requiresSeat:
          admission.selectedSeatType != LibrarySeatType.halfTimeOpenSeating,
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
          mode: admission.paymentMode,
          onModeChanged: admission.setPaymentMode,
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
    final configuration = ref.watch(libraryConfigurationProvider);
    if (!configuration.fullTimeEnabled &&
        admission.membership == MembershipType.fullTime) {
      admission.membership = MembershipType.halfTime;
    } else if (!configuration.halfTimeEnabled &&
        admission.membership == MembershipType.halfTime) {
      admission.membership = MembershipType.fullTime;
    }
    final enabledSections = configuration.enabledSections;
    admission.selectedSectionId ??= enabledSections.isEmpty
        ? null
        : enabledSections.first.id;
    final enabledPeriods = configuration.membershipPeriodsForSection(
      admission.selectedSectionId,
    );
    if (admission.period != null &&
        !enabledPeriods.contains(admission.period)) {
      admission.choosePeriod(enabledPeriods.first);
    }
    final pricing = admission.pricing;
    final categoryPricing = (MembershipType type) =>
        configuration.pricingForSection(
          admission.selectedSectionId,
          isFullTime: type == MembershipType.fullTime,
        );

    final content = Column(
      children: [
        if (enabledSections.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Library Section',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: enabledSections
                  .map(
                    (section) => ChoiceChip(
                      avatar: CircleAvatar(
                        radius: 5,
                        backgroundColor: section.color,
                      ),
                      label: Text(section.name),
                      selected: admission.selectedSectionId == section.id,
                      onSelected: (_) {
                        admission.selectedSectionId = section.id;
                        admission.setManualAmount(null);
                        final sectionPeriods = configuration
                            .membershipPeriodsForSection(section.id);
                        if (admission.period != null &&
                            !sectionPeriods.contains(admission.period)) {
                          admission.choosePeriod(sectionPeriods.first);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        MembershipSelector(
          selectedCategory: admission.category,
          selected: admission.membership,
          fullTimeMonthly: categoryPricing(MembershipType.fullTime).monthly,
          halfTimeMonthly: categoryPricing(MembershipType.halfTime).monthly,
          shifts: pricing.halfTimeShifts,
          selectedShift: admission.selectedHalfTimeShift,
          onCategoryChanged: admission.chooseCategory,
          onChanged: admission.chooseMembership,
          onShiftChanged: admission.setHalfTimeShift,
          fullTimeEnabled: configuration.fullTimeEnabled,
          halfTimeEnabled: configuration.halfTimeEnabled,
          showCategorySelector: false,
          enabledSeatTypes: configuration.seatTypes,
          selectedSeatType: admission.selectedSeatType,
          onSeatTypeChanged: admission.chooseSeatType,
        ),
        const SizedBox(height: 22),
        PricingSelector(
          selected: admission.period,
          pricing: categoryPricing(admission.membership),
          enabledPeriods: enabledPeriods,
          onChanged: admission.choosePeriod,
        ),
        if (admission.period != null &&
            admission.period != MembershipPeriod.custom) ...[
          const SizedBox(height: 14),
          TextFormField(
            key: ValueKey(
              '${admission.selectedSectionId}-${admission.period?.name}',
            ),
            initialValue: admission.fee.toStringAsFixed(2),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Membership Price',
              prefixText: '₹ ',
            ),
            onChanged: (value) =>
                admission.setManualAmount(double.tryParse(value.trim())),
          ),
        ],
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
    0 => true,
    1 => admission.pricingValid,
    2 =>
      admission.selectedSeatType == LibrarySeatType.halfTimeOpenSeating ||
          admission.selectedSeat != null,
    _ => true,
  };
  String get _membership =>
      '${admission.selectedSeatType.label} (${admission.category.shortLabel})';
  String get _seat =>
      admission.selectedSeatType != LibrarySeatType.halfTimeOpenSeating
      ? admission.selectedSeat ?? ''
      : admission.selectedHalfTimeShift != null
      ? 'Flexible (${admission.selectedHalfTimeShift})'
      : 'Flexible Seating';

  Future<void> _next() async {
    if (admission.step == 0 && !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_canContinue) return;
    if (admission.step < 4) {
      admission.next();
      return;
    }
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Library ID missing. Please log in again.',
      );
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final studentId = 'std_${DateTime.now().millisecondsSinceEpoch}';
    final receiptNo =
        'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final studentModel = StudentModel(
      id: studentId,
      name: name.text.trim(),
      email: '',
      phone: phone.text.trim(),
      gender: 'Male',
      assignedSeat: admission.selectedSeat,
      shift: admission.selectedHalfTimeShift ?? 'Full Day',
      planName: _membership,
      membershipPeriod: admission.period?.name,
      seatType: admission.selectedSeatType.name,
      sectionId: admission.selectedSectionId,
      monthlyFee: admission.fee,
      joiningDate: DateTime.now(),
      validUntil: DateTime.now().add(
        Duration(days: admission.totalDays > 0 ? admission.totalDays : 30),
      ),
      status: 'Active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final paymentModel = PaymentModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: name.text.trim(),
      amount: admission.fee,
      netAmount: admission.fee,
      paymentMode: admission.paymentMode.name,
      receiptNumber: receiptNo,
      paymentDate: DateTime.now(),
    );

    final receiptModel = ReceiptModel(
      receiptNumber: receiptNo,
      studentId: studentId,
      studentName: name.text.trim(),
      paymentId: paymentModel.id,
      amount: admission.fee,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(studentsRepositoryProvider)
          .processAdmissionTransaction(
            libraryId: libraryId,
            student: studentModel,
            seatNumber: admission.selectedSeat,
            payment: paymentModel,
            receipt: receiptModel,
          );
      ref.invalidate(studentsStreamProvider);
      ref.invalidate(paymentsStreamProvider);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        admission.completed = true;
        final initials = name.text
            .trim()
            .split(' ')
            .map((e) => e.isEmpty ? '' : e[0])
            .take(2)
            .join();
        created = Student(
          id: DateTime.now().millisecondsSinceEpoch % 10000,
          name: name.text.trim(),
          phone: phone.text.trim(),
          seat: _seat,
          joined: admission.joiningDisplay,
          expiry: admission.expiryDisplay,
          fee: admission.fee,
          payment: PaymentStatus.paid,
          membership: admission.membership,
          seatType: admission.selectedSeatType.name,
          sectionId: admission.selectedSectionId,
          membershipPeriod: admission.period?.name,
          initials: initials,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ErrorHandler.showErrorSnackBar(context, e);
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
      onPrint: () => ReceiptPdfViewerScreen.open(context, created!),
      onShare: () => ReceiptPdfViewerScreen.open(context, created!),
      onDone: () => Navigator.pop(context),
    );
  }
}
