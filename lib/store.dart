import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'notifications.dart';

class WalletStore extends ChangeNotifier {
  static const _kTxs = 'mahfazaty_txs';
  static const _kDebts = 'mahfazaty_debts';
  static const _kJam3eyat = 'mahfazaty_jam3eyat';

  List<WalletTx> txs = [];
  List<Debt> debts = [];
  List<Jam3eya> jam3eyat = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    txs = _decode(prefs.getString(_kTxs), WalletTx.fromJson);
    debts = _decode(prefs.getString(_kDebts), Debt.fromJson);
    jam3eyat = _decode(prefs.getString(_kJam3eyat), Jam3eya.fromJson);
    txs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  static List<T> _decode<T>(
    String? raw,
    T Function(Map<String, dynamic>) from,
  ) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => from(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kTxs,
      jsonEncode(txs.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kDebts,
      jsonEncode(debts.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kJam3eyat,
      jsonEncode(jam3eyat.map((e) => e.toJson()).toList()),
    );
    // أي تعديل بيأثر على التذكيرات: راجع جدولة الإشعارات
    unawaited(ReminderService.instance.syncFromStore(debts, jam3eyat));
  }

  // ---------- العمليات ----------

  void addTx(WalletTx tx) {
    txs.insert(0, tx);
    txs.sort((a, b) => b.date.compareTo(a.date));
    _save();
    notifyListeners();
  }

  /// تعديل عملية موجودة (القفل اليومي بيتفرض من الواجهة ومن الشيت)
  void updateTx(WalletTx updated) {
    final i = txs.indexWhere((t) => t.id == updated.id);
    if (i < 0) return;
    txs[i] = updated;
    txs.sort((a, b) => b.date.compareTo(a.date));
    _save();
    notifyListeners();
  }

  void deleteTx(String id) {
    txs.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  double get balance {
    double total = 0;
    for (final t in txs) {
      total += t.type == TxType.income ? t.amount : -t.amount;
    }
    return total;
  }

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  double get monthIncome {
    final now = DateTime.now();
    return txs
        .where((t) => t.type == TxType.income && _sameMonth(t.date, now))
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get monthExpense {
    final now = DateTime.now();
    return txs
        .where((t) => t.type == TxType.expense && _sameMonth(t.date, now))
        .fold(0.0, (s, t) => s + t.amount);
  }

  /// أسماء التصنيفات اللي المستخدم كتبها قبل كده (من غير اقتراحات جاهزة)
  List<String> get categories {
    final set = <String>{};
    for (final t in txs) {
      if (t.category.trim().isNotEmpty) set.add(t.category.trim());
    }
    return set.toList();
  }

  List<WalletTx> get recent => txs.take(8).toList();

  /// مصاريف آخر ٧ أيام (الأقدم للأحدث)
  List<double> get last7DaysExpense {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final next = day.add(const Duration(days: 1));
      return txs
          .where(
            (t) =>
                t.type == TxType.expense &&
                !t.date.isBefore(day) &&
                t.date.isBefore(next),
          )
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  /// مصاريف الشهر الحالي متجمعة حسب التصنيف
  Map<String, double> get expenseByCategoryThisMonth {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final t in txs) {
      if (t.type == TxType.expense && _sameMonth(t.date, now)) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  /// دخل ومصروف آخر ٦ شهور (الأقدم للأحدث)
  List<({DateTime month, double income, double expense})> get last6Months {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      double inc = 0, exp = 0;
      for (final t in txs) {
        if (_sameMonth(t.date, m)) {
          if (t.type == TxType.income) {
            inc += t.amount;
          } else {
            exp += t.amount;
          }
        }
      }
      return (month: m, income: inc, expense: exp);
    });
  }

  // ---------- سلف ودين ----------

  void addDebt(Debt debt) {
    debts.insert(0, debt);
    _save();
    notifyListeners();
  }

  void toggleDebtSettled(String id) {
    final d = debts.firstWhere((e) => e.id == id);
    d.settled = !d.settled;
    d.settledAt = d.settled ? DateTime.now() : null;
    _save();
    notifyListeners();
  }

  /// تحديد/إلغاء يوم التذكير بتسديد الدين
  void setDebtReminder(String id, DateTime? date) {
    final d = debts.firstWhere((e) => e.id == id);
    d.remindAt = date;
    _save();
    notifyListeners();
  }

  void deleteDebt(String id) {
    debts.removeWhere((d) => d.id == id);
    _save();
    notifyListeners();
  }

  double totalOwedToMe() => debts
      .where((d) => d.direction == DebtDirection.owedToMe && !d.settled)
      .fold(0.0, (s, d) => s + d.amount);

  double totalIOwe() => debts
      .where((d) => d.direction == DebtDirection.iOwe && !d.settled)
      .fold(0.0, (s, d) => s + d.amount);

  // ---------- جمعيات ----------

  void addJam3eya(Jam3eya j) {
    jam3eyat.insert(0, j);
    _save();
    notifyListeners();
  }

  void toggleJam3eyaMonth(String id, int monthIndex1Based) {
    final j = jam3eyat.firstWhere((e) => e.id == id);
    j.paidMonths[monthIndex1Based - 1] = !j.paidMonths[monthIndex1Based - 1];
    _save();
    notifyListeners();
  }

  void toggleJam3eyaReceived(String id) {
    final j = jam3eyat.firstWhere((e) => e.id == id);
    j.received = !j.received;
    _save();
    notifyListeners();
  }

  /// تحديد/إلغاء يوم التذكير بقسط الجمعية
  void setJam3eyaReminder(String id, DateTime? date) {
    final j = jam3eyat.firstWhere((e) => e.id == id);
    j.remindAt = date;
    _save();
    notifyListeners();
  }

  void deleteJam3eya(String id) {
    jam3eyat.removeWhere((j) => j.id == id);
    _save();
    notifyListeners();
  }

  double get activeJam3eyatMonthly => jam3eyat
      .where((j) => !j.isComplete)
      .fold(0.0, (s, j) => s + j.monthlyAmount);
}
