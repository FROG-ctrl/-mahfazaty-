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

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key, required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    final toMe = store.totalOwedToMe();
    final onMe = store.totalIOwe();
    final net = toMe - onMe;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDebt(context, store),
            backgroundColor: AppColors.emerald,
            icon: Icon(Icons.add, color: Colors.white),
            label: AppText(
              'سلف جديد',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AppText(
                    'سلف ودين',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DebtSummaryCard(
                          title: 'لي عند الناس',
                          value: toMe,
                          icon: Icons.call_received,
                          color: AppColors.income,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _DebtSummaryCard(
                          title: 'عليا للناس',
                          value: onMe,
                          icon: Icons.call_made,
                          color: AppColors.expense,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _DebtSummaryCard(
                          title: 'الصافي',
                          value: net,
                          icon: Icons.balance,
                          color: net >= 0
                              ? AppColors.emerald
                              : AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: TabBar(
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  tabs: [
                    Tab(text: 'لي 💰'),
                    Tab(text: 'عليا 🧾'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _DebtList(store: store, direction: DebtDirection.owedToMe),
                _DebtList(store: store, direction: DebtDirection.iOwe),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final double value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 6),
            AppText(
              title,
              style: TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
            SizedBox(height: 2),
            AppText(
              fmtMoney(value),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtList extends StatelessWidget {
  const _DebtList({required this.store, required this.direction});

  final WalletStore store;
  final DebtDirection direction;

  @override
  Widget build(BuildContext context) {
    final all = store.debts.where((d) => d.direction == direction).toList();
    final open = all.where((d) => !d.settled).toList();
    final settled = all.where((d) => d.settled).toList();

    if (all.isEmpty) {
      return EmptyState(
        lottie: 'assets/lottie/coins.json',
        title: direction == DebtDirection.owedToMe
            ? 'محدش مدينلك بحاجة'
            : 'معليكش دين لحد',
        subtitle: 'أي سلف جديد هيتسجل هنا وتفضل عارف كل مليم',
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        ...open.map((d) => _DebtCard(debt: d, store: store)),
        if (settled.isNotEmpty) ...[
          SectionTitle('اتسدت ✅'),
          ...settled.map((d) => _DebtCard(debt: d, store: store)),
        ],
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt, required this.store});

  final Debt debt;
  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    final isToMe = debt.direction == DebtDirection.owedToMe;
    final color = isToMe ? AppColors.income : AppColors.expense;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Card(
        child: Opacity(
          opacity: debt.settled ? 0.55 : 1,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: AppText(
                debt.person.isEmpty ? '؟' : debt.person.characters.first,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
            title: AppText(
              debt.person,
              translate: false,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                decoration: debt.settled ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: AppText(
              [
                fmtDay(debt.date),
                if (debt.note.isNotEmpty) debt.note,
                if (debt.remindAt != null && !debt.settled)
                  '🔔 ${fmtDay(debt.remindAt!)}',
                if (debt.settled) 'اتسدت',
              ].join(' • '),
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  fmtMoney(debt.amount),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.muted, size: 20),
                  onSelected: (v) async {
                    if (v == 'settle') {
                      store.toggleDebtSettled(debt.id);
                    } else if (v == 'delete') {
                      store.deleteDebt(debt.id);
                    } else if (v == 'remind') {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            debt.remindAt ?? today.add(Duration(days: 1)),
                        firstDate: today,
                        lastDate: today.add(Duration(days: 365 * 5)),
                        helpText: tr('فكرني بالتسديد يوم'),
                      );
                      if (picked != null) {
                        store.setDebtReminder(debt.id, picked);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: AppText(
                                'هفكرك بالتسديد يوم ${fmtDay(picked)} 🔔',
                              ),
                            ),
                          );
                        }
                      }
                    } else if (v == 'unremind') {
                      store.setDebtReminder(debt.id, null);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'settle',
                      child: AppText(
                        debt.settled ? 'رجعها غير مسددة' : 'تم التسديد ✅',
                      ),
                    ),
                    if (!debt.settled)
                      PopupMenuItem(
                        value: 'remind',
                        child: AppText(
                          debt.remindAt == null
                              ? 'تذكير بالتسديد 🔔'
                              : 'تغيير ميعاد التذكير 🔔',
                        ),
                      ),
                    if (debt.remindAt != null)
                      PopupMenuItem(
                        value: 'unremind',
                        child: AppText('إلغاء التذكير 🔕'),
                      ),
                    PopupMenuItem(value: 'delete', child: AppText('امسح 🗑')),
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

void _showAddDebt(BuildContext context, WalletStore store) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddDebtSheet(store: store),
    ),
  );
}

class _AddDebtSheet extends StatefulWidget {
  const _AddDebtSheet({required this.store});

  final WalletStore store;

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  DebtDirection _direction = DebtDirection.owedToMe;
  final _person = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _person.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amount.text.trim());
    if (_person.text.trim().isEmpty) {
      setState(() => _error = 'اكتب اسم الشخص');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'اكتب مبلغ صحيح');
      return;
    }
    widget.store.addDebt(
      Debt(
        person: _person.text.trim(),
        amount: amount,
        direction: _direction,
        note: _note.text.trim(),
      ),
    );
    Navigator.of(context).pop();
    showSuccessOverlay(context, message: 'اتسجل السلف ✅');
  }

  @override
  Widget build(BuildContext context) {
    final isToMe = _direction == DebtDirection.owedToMe;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Lottie.asset('assets/lottie/coins.json', height: 90)),
          SizedBox(height: 6),
          SegmentedButton<DebtDirection>(
            segments: [
              ButtonSegment(
                value: DebtDirection.owedToMe,
                label: AppText('لي (هيرجعهولي)'),
                icon: Icon(Icons.call_received),
              ),
              ButtonSegment(
                value: DebtDirection.iOwe,
                label: AppText('عليا (لازم أرده)'),
                icon: Icon(Icons.call_made),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (s) => setState(() => _direction = s.first),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _person,
            decoration: InputDecoration(
              labelText: tr('اسم الشخص'),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: tr('المبلغ'),
              suffixText: 'ج.م',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: tr('ملاحظة (اختياري)'),
              prefixIcon: Icon(Icons.notes),
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
          SizedBox(height: 18),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: isToMe ? AppColors.income : AppColors.expense,
            ),
            child: AppText(
              isToMe ? 'سجل إنه ليك' : 'سجل إنه عليك',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
