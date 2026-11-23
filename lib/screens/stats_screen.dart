import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    final byCat = store.expenseByCategoryThisMonth.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final months = store.last6Months;
    final monthTotal = store.monthExpense;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            'الإحصائيات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SectionTitle('مصاريف الشهر حسب التصنيف'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: byCat.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'مفيش مصاريف الشهر ده لسه',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            CategoryDonut(entries: byCat.take(8).toList()),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إجمالي الشهر',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    fmtMoney(monthTotal),
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.emeraldDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...byCat.map((e) {
                          final i = byCat.indexOf(e);
                          final pct = monthTotal == 0
                              ? 0.0
                              : e.value / monthTotal * 100;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor:
                                      CategoryDonut.palette[i %
                                          CategoryDonut.palette.length],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  fmtMoney(e.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ),
          const SectionTitle('الدخل مقابل المصروف (آخر ٦ شهور)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(AppColors.income, 'دخل'),
                      const SizedBox(width: 16),
                      _legendDot(AppColors.expense, 'مصروف'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MonthlyBars(
                    months: months.map((m) => m.month).toList(),
                    income: months.map((m) => m.income).toList(),
                    expense: months.map((m) => m.expense).toList(),
                    labels: months
                        .map(
                          (m) => fmtMonth(
                            m.month,
                          ).replaceAll(RegExp(r'\s\d{4}'), ''),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    children: [
      CircleAvatar(radius: 5, backgroundColor: color),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
