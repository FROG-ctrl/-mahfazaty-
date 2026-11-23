import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// غلاف بسيط حوالين Firebase Auth.
///
/// لو google-services.json مش موجود وقت البناء، [Firebase.initializeApp]
/// بيرمي استثناء، وساعتها [isReady] بتفضل false والتطبيق بيكمل
/// بوضع محلي عادي من غير حسابات.
class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  bool _ready = false;

  /// هل ربط Firebase شغال فعلاً؟
  bool get isReady => _ready;

  User? get currentUser => _ready ? FirebaseAuth.instance.currentUser : null;

  bool get isSignedIn => currentUser != null;

  String? get displayName => currentUser?.displayName;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _ready = true;
      FirebaseAuth.instance.authStateChanges().listen((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Firebase غير مهيأ: $e');
      _ready = false;
    }
  }

  /// يرجع null لو العملية نجحت، أو رسالة خطأ عربية.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_ready) return 'ربط الحسابات لسه مش متفعل في النسخة دي.';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return 'حصل خطأ غير متوقع. جرب تاني.';
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!_ready) return 'ربط الحسابات لسه مش متفعل في النسخة دي.';
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return 'حصل خطأ غير متوقع. جرب تاني.';
    }
  }

  Future<String?> resetPassword(String email) async {
    if (!_ready) return 'ربط الحسابات لسه مش متفعل في النسخة دي.';
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return 'حصل خطأ غير متوقع. جرب تاني.';
    }
  }

  Future<void> signOut() async {
    if (_ready) await FirebaseAuth.instance.signOut();
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'الإيميل ده مش صحيح.';
      case 'user-disabled':
        return 'الحساب ده متعطل.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'الإيميل أو كلمة السر مش صح.';
      case 'email-already-in-use':
        return 'الإيميل ده متسجل بيه قبل كده. جرب تسجل دخول.';
      case 'weak-password':
        return 'كلمة السر ضعيفة، لازم ٦ حروف على الأقل.';
      case 'too-many-requests':
        return 'محاولات كتير غلط. استنى شوية وجرب تاني.';
      case 'network-request-failed':
        return 'مفيش نت. اتأكد من الاتصال وجرب تاني.';
      default:
        return 'مش قادر أكمل العملية دلوقتي (${e.code}).';
    }
  }
}
