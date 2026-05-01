import 'package:flutter/material.dart';
import 'package:mobile_acc/main.dart';
import '../../data/datasources/database_helper.dart';

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
  final _dbHelper = DatabaseHelper();

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
      backgroundColor: Colors.white,
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
                // حقل الاسم (فقط في حالة التسجيل)
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

              // حقل رقم الموبايل
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
              
              // حقل كلمة المرور
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
              
              // زر الدخول / التسجيل
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (_isLogin) {
                      _handleLogin();
                    } else {
                      _handleSignup();
                    }
                  },
                  child: Text(_isLogin ? "دخول" : "تسجيل",
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // التبديل بين الدخول والتسجيل
              TextButton(
                onPressed: () {
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
    final phone = _phoneController.text;
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      _showError('برجاء إدخال رقم الموبايل وكلمة المرور');
      return;
    }

    if (phone.length != 11) {
      _showError('رقم الموبايل يجب أن يكون 11 رقم');
      return;
    }

    final user = await _dbHelper.loginUser(phone, password);
    if (user != null) {
      _navigateToHome();
    } else {
      _showError('رقم الموبايل أو كلمة المرور غير صحيحة');
    }
  }

  void _handleSignup() async {
    final name = _nameController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;

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

    final exists = await _dbHelper.checkPhoneExists(phone);
    if (exists) {
      _showError('رقم الموبايل مسجل بالفعل');
      return;
    }

    await _dbHelper.registerUser(name, phone, password);
    _navigateToHome();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainAccountingPage(),
      ),
    );
  }
}