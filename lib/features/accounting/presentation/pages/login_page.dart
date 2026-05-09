import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_acc/main.dart';
import 'package:mobile_acc/services/firebase_auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

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
              Text(_isLogin ? "login".tr() : "create_new_account".tr(),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C))),
              const SizedBox(height: 30),
              
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "full_name".tr(),
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
                  labelText: "mobile_number".tr(),
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
                  labelText: "password".tr(),
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
                    : Text(_isLogin ? "enter".tr() : "register".tr(),
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
                  _isLogin ? "don't_have_an_account_register_now".tr() : "already_have_an_account_login".tr(),
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
      _showError('please_enter_mobile_number_and_password'.tr());
      return;
    }

    if (phone.length != 11) {
      _showError('mobile_number_must_be_11_digits'.tr());
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(phone: phone, password: password);
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showError(FirebaseAuthService.getArabicError(e));
    } catch (e) {
      _showError('an_unexpected_error_occurred'.tr());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSignup() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('please_fill_all_fields'.tr());
      return;
    }

    if (phone.length != 11) {
      _showError('mobile_number_must_be_11_digits'.tr());
      return;
    }

    if (password.length < 6) {
      _showError('password_must_not_be_less_than_6_characters'.tr());
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUp(name: name, phone: phone, password: password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('account_created_successfully_please_login'.tr()),
          backgroundColor: const Color(0xFF00695C),
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
      _showError('an_unexpected_error_occurred'.tr());
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