import 'package:intl/intl.dart';

String money(num value) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
).format(value);
String phoneDigits(String value) => value.replaceAll(RegExp(r'\D'), '');
