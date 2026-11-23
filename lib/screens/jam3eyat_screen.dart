import '../l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/success_overlay.dart';

class Jam3eyatScreen extends StatelessWidget {
  const Jam3eyatScreen({super.key, required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    final active = store.jam3eyat.where((j) => !j.isComplete).toList();
    final done = store.jam3eyat.where((j) => j.isComplete).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddJam3eya(context, store),
          backgroundColor: AppColors.gold,
          icon: Icon(Icons.add, color: Colors.white),
          label: AppText(
            'جمعية جديدة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            AppText(
              'الجمعيات',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Lottie.asset('assets/lottie/money.json', width: 74),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            active.isEmpty
                                ? 'مفيش جمعيات شغالة'
                                : '${active.length} جمعية شغالة',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          AppText(
                            active.isEmpty
                                ? 'اعمل جمعية وتابع أقساطك شهر بشهر'
                                : 'بتدفع ${fmtMoney(store.activeJam3eyatMonthly)} كل شهر',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (store.jam3eyat.isEmpty)
              Card(
                child: EmptyState(
                  lottie: 'assets/lottie/money.json',
                  title: 'لسه مفيش جمعيات',
                  subtitle:
                      'ضيف الجمعية بعدد شهورها وقسطها الشهري، وهنحسبلك هتقبض كام وإمتى',
                  actionLabel: 'أضف أول جمعية',
                  onAction: () => _showAddJam3eya(context, store),
                ),
              )
            else ...[
              ...active.map((j) => _Jam3eyaCard(jam3eya: j, store: store)),
              if (done.isNotEmpty) ...[
                SectionTitle('خلصت 🎉'),
                ...done.map((j) => _Jam3eyaCard(jam3eya: j, store: store)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Jam3eyaCard extends StatelessWidget {
  const _Jam3eyaCard({required this.jam3eya, required this.store});

  final Jam3eya jam3eya;
  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    final progress = jam3eya.monthsCount == 0
        ? 0.0
        : jam3eya.paidCount / jam3eya.monthsCount;
    final current = jam3eya.currentMonthIndex;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showJam3eyaDetails(context, store, jam3eya),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.groups,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AppText(
                        jam3eya.name,
                        translate: false,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: jam3eya.remindAt == null
                          ? 'تذكير بميعاد القسط'
                          : 'تذكير يوم ${fmtDay(jam3eya.remindAt!)}',
                      icon: Icon(
                        jam3eya.remindAt == null
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        size: 20,
                        color: jam3eya.remindAt == null
                            ? AppColors.muted
                            : AppColors.gold,
                      ),
                      onPressed: () =>
                          _pickJam3eyaReminder(context, store, jam3eya),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: jam3eya.isComplete
                            ? AppColors.income.withValues(alpha: 0.1)
                            : AppColors.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        jam3eya.isComplete
                            ? 'خلصت'
                            : (jam3eya.received ? 'قبضتها 💰' : 'شغالة'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: jam3eya.isComplete
                              ? AppColors.income
                              : AppColors.emerald,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Color(0xFFEEF2F1),
                    valueColor: AlwaysStoppedAnimation(AppColors.emerald),
                  ),
                ),
                SizedBox(height: 8),
                AppText(
                  'دفعت ${jam3eya.paidCount} من ${jam3eya.monthsCount} شهر'
                  '${current != null && !jam3eya.isComplete ? ' • إحنا في الشهر $current' : ''}',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    InfoChip(
                      Icons.payments_outlined,
                      'القسط: ${fmtMoney(jam3eya.monthlyAmount)}',
                    ),
                    if (jam3eya.remindAt != null && !jam3eya.isComplete)
                      InfoChip(
                        Icons.notifications_active,
                        'تذكير ${fmtDay(jam3eya.remindAt!)}',
                        color: AppColors.gold,
                      ),
                    InfoChip(
                      Icons.calendar_month_outlined,
                      '${jam3eya.monthsCount} شهور',
                    ),
                    InfoChip(
                      Icons.savings_outlined,
                      jam3eya.received
                          ? 'قبضت ${fmtMoney(jam3eya.totalPot)}'
                          : 'هتقبض ${fmtMoney(jam3eya.totalPot)} في ${fmtMonth(jam3eya.receiveDate)}',
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// اختيار/تغيير/إلغاء يوم التذكير بقسط الجمعية
Future<void> _pickJam3eyaReminder(
  BuildContext context,
  WalletStore store,
  Jam3eya j,
) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (j.remindAt != null) {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText('تذكير القسط 🔔'),
        content: AppText(
          'هفكرك بقسط جمعية "${j.name}" يوم ${fmtDay(j.remindAt!)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'clear'),
            child: AppText('إلغاء التذكير'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'close'),
            child: AppText('سيبه زي ما هو'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'change'),
            child: AppText('غير الميعاد'),
          ),
        ],
      ),
    );
    if (action == 'clear') {
      store.setJam3eyaReminder(j.id, null);
      return;
    }
    if (action != 'change') return;
  }
  if (!context.mounted) return;
  final picked = await showDatePicker(
    context: context,
    initialDate: j.remindAt ?? today.add(Duration(days: 1)),
    firstDate: today,
    lastDate: today.add(Duration(days: 365 * 5)),
    helpText: tr('فكرني بقسط الجمعية يوم'),
  );
  if (picked != null) {
    store.setJam3eyaReminder(j.id, picked);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText('هفكرك بقسط "${j.name}" يوم ${fmtDay(picked)} 🔔'),
        ),
      );
    }
  }
}

void _showJam3eyaDetails(BuildContext context, WalletStore store, Jam3eya j) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _Jam3eyaDetails(store: store, jam3eya: j),
  );
}

class _Jam3eyaDetails extends StatelessWidget {
  const _Jam3eyaDetails({required this.store, required this.jam3eya});

  final WalletStore store;
  final Jam3eya jam3eya;

  @override
  Widget build(BuildContext context) {
    final j = jam3eya;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          AppText(
            j.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          AppText(
            'بدأت ${fmtMonth(j.monthDate(1))} • القسط ${fmtMoney(j.monthlyAmount)} • الإجمالي ${fmtMoney(j.totalPot)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InfoChip(
                Icons.savings_outlined,
                'دفعت: ${fmtMoney(j.paidSoFar)}',
              ),
              SizedBox(width: 8),
              InfoChip(
                Icons.hourglass_bottom,
                'فاضل: ${fmtMoney(j.remaining)}',
                color: AppColors.expense,
              ),
            ],
          ),
          SectionTitle('شهور الجمعية'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(j.monthsCount, (i) {
              final idx = i + 1;
              final paid = j.paidMonths[i];
              final isReceive = idx == j.receiveMonthIndex;
              final isCurrent = idx == j.currentMonthIndex;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  store.toggleJam3eyaMonth(j.id, idx);
                  Navigator.of(context).pop();
                  _showJam3eyaDetails(context, store, j);
                },
                child: Container(
                  width: 88,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: paid
                        ? AppColors.emerald
                        : isReceive
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : Color(0xFFF1F4F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isReceive
                          ? AppColors.gold
                          : isCurrent
                          ? AppColors.emerald
                          : Colors.transparent,
                      width: isReceive || isCurrent ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      AppText(
                        fmtMonth(
                          j.monthDate(idx),
                        ).replaceAll(RegExp(r'\s\d{4}'), ''),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: paid
                              ? Colors.white
                              : isReceive
                              ? AppColors.gold
                              : AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      AppText(
                        isReceive
                            ? 'قبضتك 🎉'
                            : paid
                            ? 'اتدفع ✓'
                            : isCurrent
                            ? 'دلوقتي'
                            : 'شهر $idx',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: paid
                              ? Colors.white.withValues(alpha: 0.9)
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8),
          AppText(
            'دوس على الشهر لما تدفع قسطه',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              store.toggleJam3eyaReceived(j.id);
              Navigator.of(context).pop();
              if (!j.received) {
                showSuccessOverlay(
                  context,
                  message: 'مبروك! قبضت ${fmtMoney(j.totalPot)} 🎉',
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: j.received ? Colors.grey : AppColors.gold,
            ),
            icon: Icon(j.received ? Icons.undo : Icons.savings_outlined),
            label: AppText(
              j.received
                  ? 'تراجع عن القبض'
                  : 'قبضت الجمعية (${fmtMoney(j.totalPot)})',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              store.deleteJam3eya(j.id);
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.delete_outline, color: AppColors.expense),
            label: AppText(
              'امسح الجمعية',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddJam3eya(BuildContext context, WalletStore store) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddJam3eyaSheet(store: store),
    ),
  );
}

class _AddJam3eyaSheet extends StatefulWidget {
  const _AddJam3eyaSheet({required this.store});

  final WalletStore store;

  @override
  State<_AddJam3eyaSheet> createState() => _AddJam3eyaSheetState();
}

class _AddJam3eyaSheetState extends State<_AddJam3eyaSheet> {
  final _name = TextEditingController();
  final _monthly = TextEditingController();
  int _monthsCount = 10;
  late int _startYear = DateTime.now().year;
  late int _startMonth = DateTime.now().month;
  int _receiveIndex = 10;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _monthly.dispose();
    super.dispose();
  }

  void _save() {
    final monthly = double.tryParse(_monthly.text.trim());
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'اكتب اسم الجمعية');
      return;
    }
    if (monthly == null || monthly <= 0) {
      setState(() => _error = 'اكتب قسط شهري صحيح');
      return;
    }
    widget.store.addJam3eya(
      Jam3eya(
        name: _name.text.trim(),
        monthlyAmount: monthly,
        monthsCount: _monthsCount,
        startYear: _startYear,
        startMonth: _startMonth,
        receiveMonthIndex: _receiveIndex.clamp(1, _monthsCount),
      ),
    );
    Navigator.of(context).pop();
    showSuccessOverlay(context, message: 'الجمعية اتسجلت ✅');
  }

  @override
  Widget build(BuildContext context) {
    final monthly = double.tryParse(_monthly.text.trim()) ?? 0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'جمعية جديدة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: tr('اسم الجمعية'),
              hintText: tr('مثلاً: جمعية الشغل'),
              prefixIcon: Icon(Icons.groups_outlined),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _monthly,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: tr('القسط الشهري'),
              suffixText: 'ج.م',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppText(
                  'عدد الشهور',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: _monthsCount > 2
                    ? () => setState(() {
                        _monthsCount--;
                        if (_receiveIndex > _monthsCount) {
                          _receiveIndex = _monthsCount;
                        }
                      })
                    : null,
                icon: Icon(Icons.remove_circle_outline),
              ),
              AppText(
                '$_monthsCount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: _monthsCount < 24
                    ? () => setState(() => _monthsCount++)
                    : null,
                icon: Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: AppText(
                  'شهر البداية',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownButton<int>(
                value: _startMonth,
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: AppText(
                      fmtMonth(
                        DateTime(_startYear, i + 1),
                      ).replaceAll(RegExp(r'\s\d{4}'), ''),
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _startMonth = v ?? 1),
              ),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: _startYear,
                items: List.generate(
                  4,
                  (i) => DropdownMenuItem(
                    value: DateTime.now().year + i - 1,
                    child: AppText('${DateTime.now().year + i - 1}'),
                  ),
                ),
                onChanged: (v) => setState(() => _startYear = v ?? _startYear),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: AppText(
                  'دورك في القبض',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownButton<int>(
                value: _receiveIndex.clamp(1, _monthsCount),
                items: List.generate(
                  _monthsCount,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: AppText(
                      'الشهر ${i + 1} (${fmtMonth(DateTime(_startYear, _startMonth + i))})',
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _receiveIndex = v ?? 1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppText(
              monthly > 0
                  ? 'هتدفع ${fmtMoney(monthly)} كل شهر لمدة $_monthsCount شهر، وتقبض ${fmtMoney(monthly * _monthsCount)} في ${fmtMonth(DateTime(_startYear, _startMonth + _receiveIndex.clamp(1, _monthsCount) - 1))} 💰'
                  : 'اكتب القسط الشهري ونشوف هتقبض كام وإمتى',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.emeraldDark,
                fontSize: 13.5,
              ),
            ),
          ),
          if (_error != null) ...[
            SizedBox(height: 8),
            AppText(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.expense),
            ),
          ],
          SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: AppColors.gold),
            child: AppText(
              'سجل الجمعية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
