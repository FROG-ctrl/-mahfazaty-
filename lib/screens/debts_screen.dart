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
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'سلف جديد',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(
                    'سلف ودين',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DebtSummaryCard(
                          title: 'عليا للناس',
                          value: onMe,
                          icon: Icons.call_made,
                          color: AppColors.expense,
                        ),
                      ),
                      const SizedBox(width: 10),
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
              const SliverToBoxAdapter(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        ...open.map((d) => _DebtCard(debt: d, store: store)),
        if (settled.isNotEmpty) ...[
          const SectionTitle('اتسدت ✅'),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Opacity(
          opacity: debt.settled ? 0.55 : 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Text(
                debt.person.isEmpty ? '؟' : debt.person.characters.first,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
            title: Text(
              debt.person,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                decoration: debt.settled ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              [
                fmtDay(debt.date),
                if (debt.note.isNotEmpty) debt.note,
                if (debt.remindAt != null && !debt.settled)
                  '🔔 ${fmtDay(debt.remindAt!)}',
                if (debt.settled) 'اتسدت',
              ].join(' • '),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fmtMoney(debt.amount),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[500],
                    size: 20,
                  ),
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
                            debt.remindAt ??
                            today.add(const Duration(days: 1)),
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365 * 5)),
                        helpText: 'فكرني بالتسديد يوم',
                      );
                      if (picked != null) {
                        store.setDebtReminder(debt.id, picked);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
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
                      child: Text(
                        debt.settled ? 'رجعها غير مسددة' : 'تم التسديد ✅',
                      ),
                    ),
                    if (!debt.settled)
                      PopupMenuItem(
                        value: 'remind',
                        child: Text(
                          debt.remindAt == null
                              ? 'تذكير بالتسديد 🔔'
                              : 'تغيير ميعاد التذكير 🔔',
                        ),
                      ),
                    if (debt.remindAt != null)
                      const PopupMenuItem(
                        value: 'unremind',
                        child: Text('إلغاء التذكير 🔕'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('امسح 🗑'),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Lottie.asset('assets/lottie/coins.json', height: 90)),
          const SizedBox(height: 6),
          SegmentedButton<DebtDirection>(
            segments: const [
              ButtonSegment(
                value: DebtDirection.owedToMe,
                label: Text('لي (هيرجعهولي)'),
                icon: Icon(Icons.call_received),
              ),
              ButtonSegment(
                value: DebtDirection.iOwe,
                label: Text('عليا (لازم أرده)'),
                icon: Icon(Icons.call_made),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (s) => setState(() => _direction = s.first),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _person,
            decoration: const InputDecoration(
              labelText: 'اسم الشخص',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'المبلغ',
              suffixText: 'ج.م',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.expense),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: isToMe ? AppColors.income : AppColors.expense,
            ),
            child: Text(
              isToMe ? 'سجل إنه ليك' : 'سجل إنه عليك',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
