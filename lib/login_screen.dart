import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'xtream_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // التحكم في عرض نافذة الدخول عبر Xtream
  bool _showXtreamForm = false;

  final _urlController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // إجبار التطبيق على الوضع العرضي الفخم منذ شاشة البداية
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _login() async {
    final url = _urlController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (url.isEmpty || user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final service = context.read<XtreamService>();
    service.configure(url, user, pass);

    try {
      final authData = await service.authenticate();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(accountData: authData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      body: SafeArea(
        child: _showXtreamForm ? _buildXtreamForm() : _buildWelcomeHub(),
      ),
    );
  }

  // الشاشة الترحيبية الاحترافية للخيارات
  Widget _buildWelcomeHub() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الشعار العلوي
          Row(
            children: [
              Text(
                'OTB',
                style: GoogleFonts.lexend(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              const Text(
                'Choose Login Method',
                style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const Spacer(),

          // بطاقات الخيارات
          Row(
            children: [
              Expanded(
                child: _buildOptionCard(
                  title: 'Xtream Codes API',
                  subtitle: 'سيرفر، اسم مستخدم وكلمة مرور',
                  icon: Icons.flash_on_rounded,
                  colors: [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
                  onTap: () => setState(() => _showXtreamForm = true),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildOptionCard(
                  title: 'Load M3U Playlist',
                  subtitle: 'رابط M3U أو ملف محلي',
                  icon: Icons.playlist_play_rounded,
                  colors: [const Color(0xFF3A1C71), const Color(0xFFD76D77)],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('سيتم تفعيل دعم M3U قريباً')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildOptionCard(
                  title: 'Device Mode',
                  subtitle: 'Phone / Tablet / Android TV',
                  icon: Icons.tv_rounded,
                  colors: [const Color(0xFF134E5E), const Color(0xFF71B280)],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الوضع الحالي: تلقائي متعدد الشاشات')),
                    );
                  },
                ),
              ),
            ],
          ),

          const Spacer(),

          // الفوتر
          const Center(
            child: Text(
              'High-Performance Native Media Engine • libmpv Powered',
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة خيار
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              radius: 24,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // شاشة إدخال بيانات السيرفر
  Widget _buildXtreamForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => setState(() => _showXtreamForm = false),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Login with Xtream Codes',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _urlController,
                hint: 'رابط السيرفر (Server URL)',
                icon: Icons.dns_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _userController,
                hint: 'اسم المستخدم (Username)',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passController,
                hint: 'كلمة المرور (Password)',
                icon: Icons.lock_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'اتصال بالسيرفر',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF161722),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
