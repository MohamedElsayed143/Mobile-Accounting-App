import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_acc/main.dart';
import 'package:mobile_acc/services/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  final _authService = FirebaseAuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, size: 80, color: Color(0xFF00695C)),
              const SizedBox(height: 20),
              Text(_isLogin ? "تسجيل الدخول" : "إنشاء حساب جديد",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C))),
              const SizedBox(height: 30),
              
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "الاسم الكامل",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "رقم الموبايل",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: _isLoading ? null : () {
                    if (_isLogin) {
                      _handleLogin();
                    } else {
                      _handleSignup();
                    }
                  },
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? "دخول" : "تسجيل",
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? "ليس لديك حساب؟ سجل الآن" : "لديك حساب بالفعل؟ سجل دخول",
                  style: const TextStyle(color: Color(0xFF00695C)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showError('برجاء إدخال رقم الموبايل وكلمة المرور');
      return;
    }

    if (phone.length != 11) {
      _showError('رقم الموبايل يجب أن يكون 11 رقم');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(phone: phone, password: password);
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showError(FirebaseAuthService.getArabicError(e));
    } catch (e) {
      _showError('حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSignup() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('برجاء ملء جميع الحقول');
      return;
    }

    if (phone.length != 11) {
      _showError('رقم الموبايل يجب أن يكون 11 رقم');
      return;
    }

    if (password.length < 6) {
      _showError('كلمة المرور يجب أن لا تقل عن 6 أحرف');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUp(name: name, phone: phone, password: password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول'),
          backgroundColor: Color(0xFF00695C),
        ),
      );
      setState(() {
        _isLogin = true;
        _nameController.clear();
        _phoneController.clear();
        _passwordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      _showError(FirebaseAuthService.getArabicError(e));
    } catch (e) {
      _showError('حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainAccountingPage(),
      ),
    );
  }
}