import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/formatters.dart';
import '../models/student.dart';

class PaymentHistorySheet extends StatelessWidget {
  final Student student;

  const PaymentHistorySheet({super.key, required this.student});

  static void open(BuildContext context, Student student) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaymentHistorySheet(student: student),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final records = _recordsFor(student);
    final paidRecords = records.where((record) => record.status == PaymentStatus.paid);
    final totalPaid = paidRecords.fold<double>(0, (total, record) => total + record.amount);

    return Container(
      height: MediaQuery.sizeOf(context).height * .82,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(student.name, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primary.withValues(alpha: .78)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL PAID', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .8)),
                  const SizedBox(height: 5),
                  Text(money(totalPaid), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${paidRecords.length} successful monthly payments', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _PaymentHistoryTile(record: records[index]),
            ),
          ),
        ],
      ),
    );
  }

  List<_PaymentRecord> _recordsFor(Student student) {
    final format = DateFormat('dd MMM yyyy');
    final joined = format.parse(student.joined);
    final expiry = format.parse(student.expiry);
    final records = <_PaymentRecord>[];
    var month = DateTime(joined.year, joined.month, joined.day);
    final lastMonth = DateTime(expiry.year, expiry.month, expiry.day);

    while (!month.isAfter(lastMonth)) {
      final isCurrent = month.year == lastMonth.year && month.month == lastMonth.month;
      final status = isCurrent ? student.payment : PaymentStatus.paid;
      records.add(_PaymentRecord(
        date: month,
        amount: student.fee,
        status: status,
        reference: 'UPI •••• ${1000 + student.id * 37 + month.month}',
      ));
      month = DateTime(month.year, month.month + 1, month.day);
    }
    return records.reversed.toList();
  }
}

class _PaymentRecord {
  final DateTime date;
  final double amount;
  final PaymentStatus status;
  final String reference;

  const _PaymentRecord({
    required this.date,
    required this.amount,
    required this.status,
    required this.reference,
  });
}

class _PaymentHistoryTile extends StatelessWidget {
  final _PaymentRecord record;

  const _PaymentHistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPaid = record.status == PaymentStatus.paid;
    final statusColor = isPaid
        ? const Color(0xFF168A4B)
        : record.status == PaymentStatus.pending
        ? const Color(0xFFC67B00)
        : colors.error;
    final statusLabel = isPaid
        ? 'Paid'
        : record.status == PaymentStatus.pending
        ? 'Pending'
        : 'Expired';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_rounded : Icons.schedule_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMMM yyyy').format(record.date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(record.reference, style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(record.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(statusLabel, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
