
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_assistant/model/message.dart';
import 'package:laennec_ai_assistant/questions/screen_questions.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_assistant/model/message.dart';
import 'package:laennec_ai_assistant/questions/screen_questions.dart';
import 'package:laennec_ai_assistant/screens/chat_screen.dart';
import 'package:laennec_ai_assistant/screens/drawer_screen.dart';
import 'package:laennec_ai_assistant/screens/medical_disclaimer_screen.dart';
import 'package:laennec_ai_assistant/screens/privacy_policy_screen.dart';
import 'package:laennec_ai_assistant/screens/terms_condition_screen.dart';
import 'package:laennec_ai_assistant/screens/update_required_screen.dart';
import 'package:laennec_ai_assistant/utils/first_launch_checker.dart';
import 'package:laennec_ai_assistant/utils/version_check_service.dart';
import 'package:laennec_ai_assistant/widgets/answer_options.dart';
import 'package:laennec_ai_assistant/widgets/buildtext_composer.dart';
import 'package:url_launcher/url_launcher.dart';
// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Loading...';
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _statusMessage = 'Checking for updates...';
    });

    try {
      // Check version first
      final versionResult = await VersionCheckService.checkVersion();

      if (mounted) {
        if (versionResult.isUpdateRequired) {
          // Show update required screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      UpdateRequiredScreen(versionResult: versionResult),
            ),
          );
        } else {
          // Version is up to date, continue with normal flow
          setState(() {
            _statusMessage = 'Version up to date. Continuing...';
          });

          await Future.delayed(const Duration(milliseconds: 2000));

          if (mounted) {
            _navigateToDisclaimer();
          }
        }
      }
    } catch (e) {
      print('Version check error: $e');
      setState(() {
        _statusMessage = 'Version check failed. Continuing...';
        _showError = true;
      });

      // In case of error, continue anyway after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _navigateToDisclaimer();
      }
    }
  }

  void _navigateToDisclaimer() {
    // Always show medical disclaimer after version check
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MedicalDisclaimerScreen()),
    );
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
            Image.asset("assets/laennec_logo.png", width: 100, height: 100),
            const SizedBox(height: 20),
            const Text(
              'Laennec AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Status message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_showError) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
