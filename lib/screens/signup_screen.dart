import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../store.dart';
import '../theme.dart';
import 'home_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.store});

  final WalletStore store;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      _error = null;
    });
    final err = await AuthService.instance.signUp(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (err == null) {
      _goHome();
    } else {
      setState(() => _error = err);
    }
  }

  String? _validateName(String? v) {
    if ((v ?? '').trim().isEmpty) return 'اكتب اسمك';
    return null;
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

  String? _validateConfirm(String? v) {
    if (v != _password.text) return 'كلمتا السر مش زي بعض';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب جديد')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اعمل حسابك وخلي فلوسك تحت السيطرة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 18),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.expense,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _name,
                    validator: _validateName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'الإيميل',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    validator: _validatePassword,
                    obscureText: _obscure,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    validator: _validateConfirm,
                    obscureText: _obscure,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(
                      labelText: 'تأكيد كلمة السر',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
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
                            'إنشاء الحساب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
