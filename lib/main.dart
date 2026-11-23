import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'auth/auth_service.dart';
import 'screens/splash_screen.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  final store = WalletStore();
  await store.load();
  await AuthService.instance.init();
  runApp(MahfazatyApp(store: store));
}

class MahfazatyApp extends StatelessWidget {
  const MahfazatyApp({super.key, required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محفظتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(store: store),
    );
  }
}
