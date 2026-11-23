import '../l10n.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'add_transaction_sheet.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final WalletStore store;

  Future<void> _onAuthTap(BuildContext context) async {
    final auth = AuthService.instance;
    if (!auth.isSignedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => LoginScreen(store: store)),
      );
      return;
    }
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText('تسجيل الخروج؟'),
        content: AppText('بياناتك المحفوظة على الموبايل هتفضل زي ما هي.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: AppText('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: AppText('خروج'),
          ),
        ],
      ),
    );
    if (sure == true) {
      await auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => LoginScreen(store: store)),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  'محفظتي',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              if (AuthService.instance.isReady)
                IconButton(
                  tooltip: AuthService.instance.isSignedIn
                      ? 'تسجيل الخروج'
                      : 'تسجيل الدخول',
                  onPressed: () => _onAuthTap(context),
                  icon: Icon(
                    AuthService.instance.isSignedIn
                        ? Icons.logout
                        : Icons.person_outline,
                    color: AppColors.muted,
                  ),
                )
              else
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.muted,
                ),
            ],
          ),
          SizedBox(height: 12),
          _BalanceCard(store: store),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  label: 'إضافة مصروف',
                  icon: Icons.arrow_upward,
                  color: AppColors.expense,
                  onTap: () => showAddTransactionSheet(
                    context,
                    store,
                    initialType: TxType.expense,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  label: 'إضافة دخل',
                  icon: Icons.arrow_downward,
                  color: AppColors.income,
                  onTap: () => showAddTransactionSheet(
                    context,
                    store,
                    initialType: TxType.income,
                  ),
                ),
              ),
            ],
          ),
          SectionTitle('مصاريف آخر ٧ أيام'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: store.last7DaysExpense.every((v) => v == 0)
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: AppText(
                          'مفيش مصاريف الأسبوع ده 🎉',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : WeeklyBars(
                      values: store.last7DaysExpense,
                      labels: List.generate(
                        7,
                        (i) => dayLetter(
                          DateTime.now().subtract(Duration(days: 6 - i)),
                        ),
                      ),
                    ),
            ),
          ),
          SectionTitle('آخر العمليات'),
          if (store.recent.isEmpty)
            Card(
              child: EmptyState(
                title: 'لسه مفيش عمليات',
                subtitle: 'سجل أول مصروف أو دخل وابدأ تتابع فلوسك',
                actionLabel: 'إضافة عملية',
                onAction: () => showAddTransactionSheet(context, store),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 6),
                itemCount: store.recent.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, indent: 64, endIndent: 16),
                itemBuilder: (context, i) =>
                    _TxTile(tx: store.recent[i], store: store),
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: -40,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            left: 40,
            bottom: -50,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'الرصيد الحالي',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              AppText(
                fmtMoney(store.balance),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'دخل الشهر',
                      value: fmtMoney(store.monthIncome),
                      icon: Icons.south_west,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'مصروف الشهر',
                      value: fmtMoney(store.monthExpense),
                      icon: Icons.north_east,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
                AppText(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 18),
              ),
              SizedBox(width: 8),
              AppText(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx, required this.store});

  final WalletTx tx;
  final WalletStore store;

  static final _icons = [
    Icons.restaurant_outlined,
    Icons.local_hospital_outlined,
    Icons.directions_bus_outlined,
    Icons.shopping_bag_outlined,
    Icons.sports_esports_outlined,
    Icons.home_outlined,
    Icons.school_outlined,
    Icons.payments_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TxType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;
    final icon = _icons[tx.category.hashCode.abs() % _icons.length];
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: AppText(
        tx.category.isEmpty ? tr(isExpense ? 'مصروف' : 'دخل') : tx.category,
        translate: false,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
      ),
      subtitle: AppText(
        tx.note.isEmpty ? fmtDay(tx.date) : '${tx.note} • ${fmtDay(tx.date)}',
        translate: false,
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            '${isExpense ? '-' : '+'} ${fmtMoney(tx.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: tx.isEditableNow
                ? 'تعديل'
                : 'التعديل متاح في يوم إضافة العملية بس',
            icon: Icon(
              tx.isEditableNow ? Icons.edit_outlined : Icons.lock_outline,
              size: 19,
              color: tx.isEditableNow ? AppColors.muted : Colors.grey[350],
            ),
            onPressed: () {
              if (tx.isEditableNow) {
                showEditTransactionSheet(context, store, tx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: AppText('مينفعش تعديل عمليات يوم سابق')),
                );
              }
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.delete_outline, size: 19, color: Colors.grey[400]),
            onPressed: () => store.deleteTx(tx.id),
          ),
        ],
      ),
    );
  }
}
