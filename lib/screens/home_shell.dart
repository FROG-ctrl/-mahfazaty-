import 'package:flutter/material.dart';

import '../store.dart';
import '../settings.dart';
import 'settings_screen.dart';
import 'debts_screen.dart';
import 'home_screen.dart';
import 'jam3eyat_screen.dart';
import 'stats_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final WalletStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final pages = [
      HomeScreen(store: store),
      DebtsScreen(store: store),
      Jam3eyatScreen(store: store),
      StatsScreen(store: store),
      SettingsScreen(store: store),
    ];
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: AppSettings.instance.isEnglish ? 'Home' : 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.handshake_outlined),
              selectedIcon: Icon(Icons.handshake),
              label: AppSettings.instance.isEnglish ? 'Debts' : 'سلف ودين',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: AppSettings.instance.isEnglish ? 'Groups' : 'جمعيات',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: AppSettings.instance.isEnglish ? 'Stats' : 'الإحصائيات',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: AppSettings.instance.isEnglish ? 'Settings' : 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
