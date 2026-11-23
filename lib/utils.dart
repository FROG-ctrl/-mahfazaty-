import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0.##', 'en');

String fmtMoney(num v) => '${_money.format(v)} ج.م';

String fmtMonth(DateTime d) => DateFormat('MMMM yyyy', 'ar').format(d);

String fmtDay(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  if (day == today) return 'النهارده';
  if (day == today.subtract(const Duration(days: 1))) return 'إمبارح';
  return DateFormat('d MMMM yyyy', 'ar').format(d);
}

const dayLetters = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

String dayLetter(DateTime d) => dayLetters[d.weekday % 7];
