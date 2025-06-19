import 'package:flutter/material.dart';
import 'package:laennec_ai_health_assistant/screens/chat_screen.dart';
import 'package:laennec_ai_health_assistant/screens/privacy_policy_screen.dart';
import 'package:laennec_ai_health_assistant/utils/first_launch_checker.dart';

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkPrivacyPolicyAndNavigate();
      }
    });
  }

  Future<void> _checkPrivacyPolicyAndNavigate() async {
    try {
      final hasAcceptedPrivacy =
          await FirstLaunchChecker.hasAcceptedPrivacyPolicy();

      if (hasAcceptedPrivacy) {
        // User has already accepted privacy policy, go to chat screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      } else {
        // First time user, show privacy policy
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
        );
      }
    } catch (e) {
      // If there's an error checking preferences, default to showing privacy policy
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset("assets/img_splash.png", width: 100, height: 100),
            const Text(
              'Laennec AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
