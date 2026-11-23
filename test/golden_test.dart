import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahfazaty/models.dart';
import 'package:mahfazaty/screens/debts_screen.dart';
import 'package:mahfazaty/screens/home_screen.dart';
import 'package:mahfazaty/screens/jam3eyat_screen.dart';
import 'package:mahfazaty/store.dart';
import 'package:mahfazaty/theme.dart';

WalletStore fakeStore() {
  final now = DateTime.now();
  final s = WalletStore();
  s.txs = [
    WalletTx(type: TxType.income, amount: 12000, category: 'مرتب', date: now),
    WalletTx(type: TxType.expense, amount: 350, category: 'علاج برد', note: 'دواء من الصيدلية', date: now),
    WalletTx(type: TxType.expense, amount: 120, category: 'مواصلات', date: now.subtract(const Duration(days: 1))),
    WalletTx(type: TxType.expense, amount: 800, category: 'مصاريف مستشفى', date: now.subtract(const Duration(days: 2))),
    WalletTx(type: TxType.expense, amount: 60, category: 'شاي المكتب', date: now.subtract(const Duration(days: 4))),
    WalletTx(type: TxType.expense, amount: 450, category: 'عزومة', date: now.subtract(const Duration(days: 6))),
  ];
  s.debts = [
    Debt(person: 'أحمد الحديد', amount: 500, direction: DebtDirection.owedToMe, note: 'شحن كاش'),
    Debt(person: 'محمود', amount: 200, direction: DebtDirection.iOwe),
    Debt(person: 'سارة', amount: 150, direction: DebtDirection.owedToMe)..settled = true,
  ];
  s.jam3eyat = [
    Jam3eya(
      name: 'جمعية الشغل',
      monthlyAmount: 500,
      monthsCount: 10,
      startYear: now.year,
      startMonth: now.month,
      receiveMonthIndex: 4,
      paidMonths: [true, true, false, false, false, false, false, false, false, false],
    ),
    Jam3eya(
      name: 'جمعية العيلة',
      monthlyAmount: 1000,
      monthsCount: 6,
      startYear: now.year,
      startMonth: now.month - 1,
      receiveMonthIndex: 6,
      paidMonths: [true, true, true, false, false, false],
    ),
  ];
  return s;
}

Future<void> loadFonts() async {
  final loader = FontLoader('Cairo')
    ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Cairo-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Cairo-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Cairo-ExtraBold.ttf'));
  await loader.load();
}

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadFonts);

  setUp(() {
    final v = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    v.physicalSize = const Size(1080, 2400);
    v.devicePixelRatio = 3.0;
  });

  testWidgets('home screen', (tester) async {
    await tester.pumpWidget(wrap(HomeScreen(store: fakeStore())));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(find.byType(HomeScreen), matchesGoldenFile('home.png'));
  });

  testWidgets('debts screen', (tester) async {
    await tester.pumpWidget(wrap(DebtsScreen(store: fakeStore())));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(find.byType(DebtsScreen), matchesGoldenFile('debts.png'));
  });

  testWidgets('jam3eyat screen', (tester) async {
    await tester.pumpWidget(wrap(Jam3eyatScreen(store: fakeStore())));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(find.byType(Jam3eyatScreen), matchesGoldenFile('jam3eyat.png'));
  });
}
