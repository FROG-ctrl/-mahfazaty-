import 'package:intl/intl.dart';
import 'settings.dart';

final _money = NumberFormat('#,##0.##', 'en');

String fmtMoney(num v) => AppSettings.instance.isEnglish
    ? '${_money.format(v)} EGP'
    : '${_money.format(v)} ج.م';

String fmtMonth(DateTime d) =>
    DateFormat('MMMM yyyy', AppSettings.instance.language).format(d);

String fmtDay(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  if (day == today) {
    return AppSettings.instance.isEnglish ? 'Today' : 'النهارده';
  }
  if (day == today.subtract(Duration(days: 1))) {
    return AppSettings.instance.isEnglish ? 'Yesterday' : 'إمبارح';
  }
  return DateFormat('d MMMM yyyy', AppSettings.instance.language).format(d);
}

final dayLetters = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

String dayLetter(DateTime d) => AppSettings.instance.isEnglish
    ? ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][d.weekday - 1]
    : dayLetters[d.weekday % 7];
