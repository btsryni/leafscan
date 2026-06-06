import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Premium welcome/onboarding splash screen for LeafScan.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-transition to main shell after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _startApp();
      }
    });
  }

  Future<void> _startApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('leafscan_onboarding_done', true);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F8C3B), // Bright leaf green
              Color(0xFFE8F5E9), // Light green-white diagonal glow
              Colors.white,      // Pure white diagonal center
              Color(0xFFE8F5E9),
              Color(0xFF0F8C3B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Main Content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Official Brand LeafScan Logo (contains Leaf & text logo)
                    Image.asset(
                      'assets/logo/logo.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // App Slogan matching Screenshot 1 (green font colors)
                    const Text(
                      'Selamat datang di LeafScan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF097E32),
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Teman pintar untuk merawat tanaman kopimu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF097E32),
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),
                    
                    // Simple modern loading indicator
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097E32)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
