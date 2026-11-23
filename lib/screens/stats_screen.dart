import '../l10n.dart';
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
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppText(
            'الإحصائيات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SectionTitle('مصاريف الشهر حسب التصنيف'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: byCat.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: AppText(
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
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'إجمالي الشهر',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  AppText(
                                    fmtMoney(monthTotal),
                                    style: TextStyle(
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
                        SizedBox(height: 14),
                        ...byCat.map((e) {
                          final i = byCat.indexOf(e);
                          final pct = monthTotal == 0
                              ? 0.0
                              : e.value / monthTotal * 100;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor:
                                      CategoryDonut.palette[i %
                                          CategoryDonut.palette.length],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: AppText(
                                    e.key,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                AppText(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(width: 8),
                                AppText(
                                  fmtMoney(e.value),
                                  style: TextStyle(
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
          SectionTitle('الدخل مقابل المصروف (آخر ٦ شهور)'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(AppColors.income, 'دخل'),
                      SizedBox(width: 16),
                      _legendDot(AppColors.expense, 'مصروف'),
                    ],
                  ),
                  SizedBox(height: 10),
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
      SizedBox(width: 5),
      AppText(
        label,
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
