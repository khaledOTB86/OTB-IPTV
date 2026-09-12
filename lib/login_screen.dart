import 'package:flutter/material.dart';
import 'xtream_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = XtreamService();
    service.configure(
      url: _serverController.text.trim(),
      user: _userController.text.trim(),
      pass: _passController.text.trim(),
    );

    try {
      final auth = await service.authenticate();
      if (auth['user_info']?['auth'] == 1) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(service: service)),
        );
      } else {
        setState(() => _errorMessage = 'بيانات الدخول غير صحيحة');
      }
    } catch (e) {
      setState(() => _errorMessage = 'تعذر الاتصال بالسيرفر، تأكد من صحة الرابط');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('OTB', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    SizedBox(width: 6),
                    Icon(Icons.play_arrow_rounded, color: Colors.redAccent, size: 36),
                    SizedBox(width: 6),
                    Text('IPTV', style: TextStyle(color: Colors.white70, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _serverController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'رابط السيرفر (Server URL / Portal)',
                    prefixIcon: Icon(Icons.dns, color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _userController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم (Username)',
                    prefixIcon: Icon(Icons.person, color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور (Password)',
                    prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
