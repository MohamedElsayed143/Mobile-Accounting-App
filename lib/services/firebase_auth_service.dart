import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

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
        return 'invalid_phone_number_or_password'.tr();
      case 'email-already-in-use':
        return 'phone_number_is_already_registered'.tr();
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      case 'network-request-failed':
        return 'no_internet_connection_please_check_your_network'.tr();
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}