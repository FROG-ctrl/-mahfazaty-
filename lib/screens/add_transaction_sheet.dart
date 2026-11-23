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

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet({required this.store, required this.initialType});

  final WalletStore store;
  final TxType initialType;

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
    widget.store.addTx(
      WalletTx(
        type: _type,
        amount: amount,
        category: _category.text.trim(),
        note: _note.text.trim(),
        date: _date,
      ),
    );
    Navigator.of(context).pop();
    showSuccessOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TxType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;
    final cats = widget.store.categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F3),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
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
          const SizedBox(height: 18),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          const SizedBox(height: 14),
          TextField(
            controller: _category,
            decoration: const InputDecoration(
              labelText: 'التصنيف (اكتب اللي انت عايزه)',
              hintText: 'مثلاً: علاج برد، مواصلات، شاي المكتب…',
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          if (cats.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: cats
                  .take(10)
                  .map(
                    (c) => ActionChip(
                      label: Text(c, style: const TextStyle(fontSize: 12.5)),
                      onPressed: () => setState(() => _category.text = c),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _date = picked);
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(fmtDay(_date)),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: color),
            child: Text(
              isExpense ? 'سجل المصروف' : 'سجل الدخل',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
