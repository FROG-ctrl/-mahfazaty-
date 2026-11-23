import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../store.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.store});

  final WalletStore store;

  static const seenKey = 'onboarding_seen_v1';

  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(seenKey) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.lottie,
    required this.title,
    required this.subtitle,
  });

  final String lottie;
  final String title;
  final String subtitle;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      lottie: 'assets/lottie/money.json',
      title: 'مصاريفك ودخلك في مكان واحد',
      subtitle:
          'سجل أي عملية في ثواني، وصنفها بالأسماء اللي تحبها، والتطبيق بيتعلم منك ويقترحها عليك بعد كده.',
    ),
    _OnboardingPage(
      lottie: 'assets/lottie/coins.json',
      title: 'سلف ودين من غير ما تنسى',
      subtitle: 'اعرف مين ليه عليك ومين لك عنده، والصافي قدامك، وسدد بضغطة واحدة.',
    ),
    _OnboardingPage(
      lottie: 'assets/lottie/success.json',
      title: 'جمعياتك محسوبة للآخر',
      subtitle:
          'القسط الشهري وعدد الشهور ودور قبضك، والتطبيق بيحسبلك هتقبض كام وإمتى بالظبط.',
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  Route<void> _fadeTo(Widget page) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, child) =>
        FadeTransition(opacity: a, child: child),
  );

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.seenKey, true);
    if (!mounted) return;
    final auth = AuthService.instance;
    final dest = (auth.isReady && !auth.isSignedIn)
        ? LoginScreen(store: widget.store)
        : HomeShell(store: widget.store);
    Navigator.of(context).pushReplacement(_fadeTo(dest));
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: _isLast ? null : _finish,
                child: Text(
                  'تخطي',
                  style: TextStyle(
                    color: _isLast ? Colors.transparent : Colors.grey[600],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(page.lottie, width: 240, repeat: true),
                        const SizedBox(height: 20),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.7,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.emerald
                        : AppColors.emerald.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _isLast ? 'يلا نبدأ' : 'التالي',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
