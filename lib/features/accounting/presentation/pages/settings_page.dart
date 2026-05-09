import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_acc/core/settings/settings_cubit.dart';
import 'package:mobile_acc/core/settings/settings_state.dart';
import 'package:mobile_acc/services/firebase_auth_service.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _editProfile() {
    final nameController = TextEditingController(text: currentUser?.displayName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                if (value.trim().length < 3) {
                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await currentUser?.updateDisplayName(nameController.text.trim());
                  if (context.mounted) {
                    setState(() {});
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تغيير كلمة المرور'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.trim().length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await currentUser?.updatePassword(passwordController.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'requires-recent-login') {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى تسجيل الخروج والدخول مجدداً لإجراء هذا التغيير لأسباب أمنية')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('حدث خطأ: ${e.message}')),
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle('الملف الشخصي'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF00695C),
                    radius: 24,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  title: Text(currentUser?.displayName ?? 'مستخدم بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(currentUser?.email?.replaceAll('@mobileacc.app', '') ?? 'لا يوجد رقم هاتف', style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF00695C)),
                    onPressed: _editProfile,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('التفضيلات'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('الوضع الليلي'),
                      secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
                      activeColor: const Color(0xFF00695C),
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        context.read<SettingsCubit>().toggleTheme(value);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('اللغة'),
                      leading: const Icon(Icons.language, color: Colors.blue),
                      trailing: DropdownButton<String>(
                        value: state.locale.languageCode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsCubit>().changeLanguage(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('الأمان'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('تغيير كلمة المرور'),
                  leading: const Icon(Icons.lock, color: Colors.orange),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: _changePassword,
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('عن التطبيق'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('رقم الإصدار'),
                      leading: const Icon(Icons.info, color: Colors.teal),
                      trailing: const Text('1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00695C),
        ),
      ),
    );
  }
}
