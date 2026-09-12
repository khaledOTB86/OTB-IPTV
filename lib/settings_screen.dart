import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> accountData;

  const SettingsScreen({super.key, required this.accountData});

  @override
  Widget build(BuildContext context) {
    final userInfo = accountData['user_info'] ?? {};
    final serverInfo = accountData['server_info'] ?? {};

    final settingsOptions = [
      {'title': 'General Settings', 'icon': Icons.settings_rounded},
      {'title': 'Time Format', 'icon': Icons.access_time_rounded},
      {'title': 'Stream Format', 'icon': Icons.video_settings_rounded},
      {'title': 'Parental Control', 'icon': Icons.lock_outline_rounded},
      {'title': 'Player Selection', 'icon': Icons.play_circle_outline_rounded},
      {'title': 'Speed Test', 'icon': Icons.speed_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'SETTINGS',
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: settingsOptions.length,
                  itemBuilder: (context, index) {
                    final item = settingsOptions[index];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'] as IconData, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Server: ${serverInfo['url'] ?? 'Active'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('Status: ${userInfo['status'] ?? 'Active'}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    Text('Max Connections: ${userInfo['max_connections'] ?? 1}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
