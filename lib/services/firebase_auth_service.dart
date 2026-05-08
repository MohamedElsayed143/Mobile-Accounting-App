import 'package:firebase_auth/firebase_auth.dart';

/// خدمة المصادقة باستخدام Firebase Auth
/// يحوّل رقم الهاتف إلى email وهمي بالصيغة: phone@mobileacc.app
/// بهذا يبقى المستخدم يُدخل رقم هاتفه كما هو دون أي تغيير في الواجهة
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// المستخدم الحالي المسجّل دخوله
  User? get currentUser => _auth.currentUser;

  /// Stream يُنبّه عند تغيّر حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// تحويل رقم الهاتف إلى email وهمي
  String _phoneToEmail(String phone) => '${phone.trim()}@mobileacc.app';

  /// تسجيل مستخدم جديد
  /// يُعيد [UserCredential] في حالة النجاح
  /// يرمي [FirebaseAuthException] في حالة الفشل
  Future<UserCredential> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // حفظ الاسم في Firebase Auth profile
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  /// تسجيل الدخول برقم الهاتف وكلمة المرور
  Future<UserCredential> signIn({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// تحويل رسائل خطأ Firebase إلى رسائل عربية مفهومة
  static String getArabicError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'رقم الموبايل مسجل بالفعل';
      case 'user-not-found':
        return 'رقم الموبايل غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-credential':
        return 'رقم الموبايل أو كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات. يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'لا يوجد اتصال بالإنترنت';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
