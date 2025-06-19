import 'package:flutter/material.dart';
import 'package:laennec_ai_health_assistant/screens/splash_screen.dart';
import 'package:laennec_ai_health_assistant/screens/privacy_policy_screen.dart';
import 'package:laennec_ai_health_assistant/utils/first_launch_checker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laennec AI Health Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AppLauncher(),
    );
  }
}

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // Small delay to ensure smooth startup
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      final hasAcceptedPrivacy =
          await FirstLaunchChecker.hasAcceptedPrivacyPolicy();

      if (hasAcceptedPrivacy) {
        // User has already accepted privacy policy, go to splash screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      } else {
        // First time user, show privacy policy
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
        );
      }
    } catch (e) {
      // If there's an error checking preferences, default to showing privacy policy
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading screen while checking preferences
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 80, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Laennec AI Health Assistant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}
