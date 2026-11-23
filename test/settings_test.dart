import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mahfazaty/settings.dart';
import 'package:mahfazaty/theme.dart';
import 'package:mahfazaty/store.dart';
import 'package:mahfazaty/screens/home_shell.dart';
import 'package:mahfazaty/screens/settings_screen.dart';
import 'package:mahfazaty/l10n.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({'mahfazaty_txs': 'keep-me'});
    await AppSettings.instance.load();
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });
  test(
    'six selections persist without changing unrelated wallet data',
    () async {
      final settings = AppSettings.instance;
      for (final id in AppSettings.themeIds) {
        await settings.setTheme(id);
        final fresh = AppSettings();
        await fresh.load();
        expect(fresh.themeId, id);
      }
      final p = await SharedPreferences.getInstance();
      expect(p.getString('mahfazaty_txs'), 'keep-me');
      await settings.setProfileName('Test Name');
      await settings.setLanguage('en');
      final fresh = AppSettings();
      await fresh.load();
      expect(fresh.profileName, 'Test Name');
      expect(fresh.language, 'en');
      expect(tr('الرصيد الحالي'), 'Current balance');
      await settings.setTheme('invalid');
      expect(settings.themeId, 'black');
    },
  );
  Widget wrap(Widget child) => AnimatedBuilder(
    animation: AppSettings.instance,
    builder: (context, _) => MaterialApp(
      theme: AppTheme.light,
      locale: Locale(AppSettings.instance.language),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
  test('unselected control text contrasts with palette surfaces', () {
    for (final id in AppSettings.themeIds) {
      AppSettings.instance.themeId = id;
      for (final bg in [
        AppTheme.light.inputDecorationTheme.fillColor!,
        AppTheme.light.colorScheme.surface,
      ]) {
        final fg = Color.alphaBlend(AppColors.ink, bg);
        final a = fg.computeLuminance();
        final b = bg.computeLuminance();
        final ratio = (a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05));
        expect(ratio, greaterThanOrEqualTo(4.5), reason: id);
      }
    }
  });
  testWidgets('settings theme tap and language selection work', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrap(SettingsScreen(store: WalletStore())));
    await tester.pumpAndSettle();
    for (final id in AppSettings.themeIds) {
      await tester.tap(find.byKey(Key('theme-$id')));
      await tester.pumpAndSettle();
      expect(AppSettings.instance.themeId, id);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(AppSettings.instance.language, 'en');
    expect(find.text('Settings'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Settings'))),
      TextDirection.ltr,
    );
    await tester.tap(find.byKey(const Key('edit-profile')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Local Test');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Local Test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('settings is reachable in the real navigation shell', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(HomeShell(store: WalletStore())));
    await tester.pump(const Duration(milliseconds: 500));
    final nav = find.byType(NavigationDestination).last;
    await tester.tap(nav);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('theme-green')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
