import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../store.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});

  final WalletStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _notice;
  bool _noticeIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => HomeShell(store: widget.store),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
      (_) => false,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    final err = await AuthService.instance.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (err == null) {
      _goHome();
    } else {
      setState(() {
        _notice = err;
        _noticeIsError = true;
      });
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _notice = 'اكتب إيميلك فوق الأول، وبعدين اضغط نسيت كلمة السر.';
        _noticeIsError = true;
      });
      return;
    }
    setState(() {
      _busy = true;
      _notice = null;
    });
    final err = await AuthService.instance.resetPassword(email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _notice = err ?? 'بعتنالك لينك إعادة تعيين كلمة السر على إيميلك.';
      _noticeIsError = err != null;
    });
  }

  void _openSignup() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignupScreen(store: widget.store),
      ),
    );
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'اكتب الإيميل';
    if (!value.contains('@') || !value.contains('.')) {
      return 'الإيميل ده مش صحيح';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if ((v ?? '').isEmpty) return 'اكتب كلمة السر';
    if (v!.length < 6) return 'كلمة السر لازم ٦ حروف على الأقل';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final firebaseReady = AuthService.instance.isReady;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [AppColors.teal, AppColors.emerald],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.gold,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'أهلاً بيك في محفظتي',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'سجل دخولك عشان تكمل',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 22),
                  if (!firebaseReady) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'الحسابات السحابية لسه بتتجهز في النسخة دي. تقدر تكمل كضيف، وبياناتك هتفضل محفوظة على موبايلك.',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_notice != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _noticeIsError
                            ? AppColors.expense.withValues(alpha: 0.08)
                            : AppColors.emerald.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _notice!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _noticeIsError
                              ? AppColors.expense
                              : AppColors.emeraldDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _email,
                    enabled: firebaseReady,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    validator: _validateEmail,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'الإيميل',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    enabled: firebaseReady,
                    obscureText: _obscure,
                    textDirection: TextDirection.ltr,
                    validator: _validatePassword,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'كلمة السر',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: firebaseReady && !_busy ? _forgot : null,
                      child: const Text(
                        'نسيت كلمة السر؟',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FilledButton(
                    onPressed: firebaseReady && !_busy ? _submit : null,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ماعندكش حساب؟',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: firebaseReady ? _openSignup : null,
                        child: const Text(
                          'اعمل حساب جديد',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'أو',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _goHome,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppColors.emerald.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'الدخول كضيف',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
