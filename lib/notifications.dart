import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';
import 'utils.dart';

/// إشعارات محلية بتفكر المستخدم بمواعيد تسديد الديون وأقساط الجمعيات.
///
/// الإشعار بيوصل للمستخدم نفسه (التطبيق مفيش فيه أرقام الطرف التاني)،
/// الساعة ٩ الصبح في اليوم المحدد.
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  static const String _channelId = 'payment_reminders';

  /// ساعة التذكير الصبح
  static const int _reminderHour = 9;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      var tzName = 'Africa/Cairo';
      try {
        final dynamic info = await FlutterTimezone.getLocalTimezone();
        if (info is String && info.isNotEmpty) {
          tzName = info;
        } else {
          final dynamic name = (info as dynamic).name;
          if (name is String && name.isNotEmpty) tzName = name;
        }
      } catch (_) {}
      try {
        tz.setLocalLocation(tz.getLocation(tzName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      }
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(initSettings);
      _ready = true;
    } catch (e) {
      debugPrint('تعذرت تهيئة الإشعارات: $e');
    }
  }

  bool get isReady => _ready;

  Future<void> _ensurePermission() async {
    if (!_ready) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    final enabled = await android.areNotificationsEnabled();
    if (enabled != true) {
      await android.requestNotificationsPermission();
    }
  }

  int _idFor(String prefix, String id) => (prefix + id).hashCode & 0x7fffffff;

  /// إعادة جدولة كل التذكيرات من بيانات المخزن (بتتلغي القديمة وبتتظبط من جديد)
  Future<void> syncFromStore(List<Debt> debts, List<Jam3eya> jam3eyat) async {
    if (!_ready) return;
    final openDebts = debts
        .where((d) => !d.settled && d.remindAt != null)
        .toList();
    final openJam3eyat = jam3eyat
        .where((j) => !j.isComplete && j.remindAt != null)
        .toList();
    await _plugin.cancelAll();
    if (openDebts.isEmpty && openJam3eyat.isEmpty) return;
    await _ensurePermission();
    final now = tz.TZDateTime.now(tz.local);
    for (final d in openDebts) {
      await _schedule(
        id: _idFor('debt', d.id),
        date: d.remindAt!,
        title: 'تذكير تسديد 💰',
        body: d.direction == DebtDirection.owedToMe
            ? 'النهارده ميعاد ${d.person} يرجعلك ${fmtMoney(d.amount)}'
            : 'النهارده ميعاد تسديد ${fmtMoney(d.amount)} لـ ${d.person}',
        now: now,
      );
    }
    for (final j in openJam3eyat) {
      await _schedule(
        id: _idFor('jam3eya', j.id),
        date: j.remindAt!,
        title: 'تذكير قسط جمعية 📅',
        body:
            'النهارده ميعاد قسط جمعية "${j.name}" (${fmtMoney(j.monthlyAmount)})',
        now: now,
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime date,
    required String title,
    required String body,
    required tz.TZDateTime now,
  }) async {
    var when = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      _reminderHour,
    );
    if (!when.isAfter(now)) {
      // لو اليوم المحدد هو النهارده ومعاد الصبح عدّى، فكره بعد دقيقة
      when = now.add(const Duration(minutes: 1));
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'تذكيرات التسديد',
          channelDescription: 'تذكير بمواعيد تسديد الديون وأقساط الجمعيات',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
