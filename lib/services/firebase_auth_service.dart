import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential> signIn({required String phone, required String password}) async {
    // نستخدم رقم الهاتف كبريد إلكتروني وهمي لتسهيل العملية
    final email = "$phone@mobileacc.app";
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({required String name, required String phone, required String password}) async {
    final email = "$phone@mobileacc.app";
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUserId => _auth.currentUser?.uid;

  static String getArabicError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'رقم الهاتف أو كلمة المرور غير صحيح';
      case 'email-already-in-use':
        return 'رقم الهاتف مسجل مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت، تأكد من اتصالك بالشبكة';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}