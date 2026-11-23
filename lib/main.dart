import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'auth/auth_service.dart';
import 'notifications.dart';
import 'screens/splash_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');
  await AppSettings.instance.load();
  final store = WalletStore();
  await store.load();
  await AuthService.instance.init();
  await ReminderService.instance.init();
  await ReminderService.instance.syncFromStore(store.debts, store.jam3eyat);
  runApp(MahfazatyApp(store: store));
}

class MahfazatyApp extends StatelessWidget {
  const MahfazatyApp({super.key, required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) => MaterialApp(
        title: 'محفظتي',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: Locale(AppSettings.instance.language),
        supportedLocales: [Locale('ar'), Locale('en')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(store: store),
      ),
    );
  }
}
