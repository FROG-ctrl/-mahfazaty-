import '../l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/success_overlay.dart';

void showAddTransactionSheet(
  BuildContext context,
  WalletStore store, {
  TxType initialType = TxType.expense,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddTransactionSheet(store: store, initialType: initialType),
    ),
  );
}

/// فتح شيت تعديل عملية موجودة (متاح في يوم إضافتها بس — بيتقفل بعدها)
void showEditTransactionSheet(
  BuildContext context,
  WalletStore store,
  WalletTx tx,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddTransactionSheet(
        store: store,
        initialType: tx.type,
        existing: tx,
      ),
    ),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet({
    required this.store,
    required this.initialType,
    this.existing,
  });

  final WalletStore store;
  final TxType initialType;

  /// لو موجود يبقى وضع تعديل عملية قديمة
  final WalletTx? existing;

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  late TxType _type = widget.initialType;
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _amount.text = ex.amount == ex.amount.roundToDouble()
          ? ex.amount.toStringAsFixed(0)
          : ex.amount.toString();
      _category.text = ex.category;
      _note.text = ex.note;
      _date = ex.date;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'اكتب مبلغ صحيح');
      return;
    }
    final ex = widget.existing;
    if (ex != null) {
      // القفل اليومي: لو يوم الإضافة عدّى والشيت لسه مفتوح، ارفض التعديل
      if (!ex.isEditableNow) {
        setState(() => _error = 'مينفعش تعديل عمليات يوم سابق');
        return;
      }
      widget.store.updateTx(
        ex.copyWith(
          type: _type,
          amount: amount,
          category: _category.text.trim(),
          note: _note.text.trim(),
          date: _date,
        ),
      );
    } else {
      widget.store.addTx(
        WalletTx(
          type: _type,
          amount: amount,
          category: _category.text.trim(),
          note: _note.text.trim(),
          date: _date,
        ),
      );
    }
    Navigator.of(context).pop();
    showSuccessOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TxType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;
    final cats = widget.store.categories;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TypeButton(
                    label: 'مصروف',
                    selected: isExpense,
                    color: AppColors.expense,
                    onTap: () => setState(() => _type = TxType.expense),
                  ),
                  _TypeButton(
                    label: 'دخل',
                    selected: !isExpense,
                    color: AppColors.income,
                    onTap: () => setState(() => _type = TxType.income),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'ج.م',
              errorText: _error,
            ),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _category,
            decoration: InputDecoration(
              labelText: tr('التصنيف (اكتب اللي انت عايزه)'),
              hintText: tr('مثلاً: علاج برد، مواصلات، شاي المكتب…'),
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          if (cats.isNotEmpty) ...[
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: cats
                  .take(10)
                  .map(
                    (c) => ActionChip(
                      label: AppText(
                        c,
                        translate: false,
                        style: TextStyle(fontSize: 12.5),
                      ),
                      onPressed: () => setState(() => _category.text = c),
                    ),
                  )
                  .toList(),
            ),
          ],
          SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: tr('ملاحظة (اختياري)'),
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) setState(() => _date = picked);
            },
            icon: Icon(Icons.calendar_month_outlined),
            label: AppText(fmtDay(_date)),
          ),
          SizedBox(height: 18),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: color),
            child: AppText(
              _isEditing
                  ? 'حفظ التعديل'
                  : isExpense
                  ? 'سجل المصروف'
                  : 'سجل الدخل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(11),
        ),
        child: AppText(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
