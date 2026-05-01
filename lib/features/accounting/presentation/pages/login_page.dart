import 'package:flutter/material.dart';
import 'package:mobile_acc/main.dart'; // تأكد أن MainAccountingPage معرفة داخل هذا الملف أو قم بعمل import لملفها الخاص

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'موظف'; // الدور الافتراضي

  @override
  void dispose() {
    _usernameController.dispose();
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
              const Text("تسجيل الدخول",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C))),
              const SizedBox(height: 30),
              // حقل اسم المستخدم
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "اسم المستخدم",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
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
              const SizedBox(height: 16),
              // اختيار الصلاحية (Role)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['مدير', 'موظف']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: InputDecoration(
                  labelText: "الصلاحية",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              // زر الدخول
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    _handleLogin();
                  },
                  child: const Text("دخول",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء إدخال اسم المستخدم')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainAccountingPage(),
      ),
    );
  }
}