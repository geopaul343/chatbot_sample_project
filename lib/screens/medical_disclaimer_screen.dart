
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
import 'package:laennec_ai_assistant/utils/first_launch_checker.dart';
import 'package:laennec_ai_assistant/widgets/answer_options.dart';
import 'package:laennec_ai_assistant/widgets/buildtext_composer.dart';
import 'package:url_launcher/url_launcher.dart';
class MedicalDisclaimerScreen extends StatefulWidget {
  const MedicalDisclaimerScreen({super.key});

  @override
  State<MedicalDisclaimerScreen> createState() =>
      _MedicalDisclaimerScreenState();
}

class _MedicalDisclaimerScreenState extends State<MedicalDisclaimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDisagree() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('Exit App'),
              ],
            ),
            content: const Text(
              'You must accept the Medical Disclaimer to use this app. Are you sure you want to exit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Exit App'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleAgree() async {
    await FirstLaunchChecker.markPrivacyPolicyAccepted();
    await FirstLaunchChecker.markFirstLaunchCompleted();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.deepPurple.shade700,
              Colors.purple.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            'assets/laennec_logo.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Laennec AI Assistant',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Medical Disclaimer, Privacy Policy & Terms',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Medical Disclaimer Section
                                _buildSimpleHeader('Medical Disclaimer'),
                                const SizedBox(height: 12),
                                _buildSimpleText(medicalDisclaimerText),

                                const SizedBox(height: 24),

                                // Privacy Policy Section
                                _buildSimpleHeader('Privacy Policy'),
                                const SizedBox(height: 12),
                                _buildPrivacyPolicySimple(),

                                const SizedBox(height: 24),

                                // Terms and Conditions Section
                                _buildSimpleHeader('Terms and Conditions'),
                                const SizedBox(height: 12),
                                _buildTermsAndConditionsSimple(),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Buttons
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _handleDisagree,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(
                                      color: Colors.red.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Decline & Quit',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleAgree,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'I understand',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Medical disclaimer text
  String get medicalDisclaimerText => '''
This app is designed for educational purposes only and does not provide medical advice, diagnosis, or treatment. The information provided should not replace professional medical consultation.

Always consult with a qualified healthcare provider before making any decisions about your health or treatment. Do not ignore professional medical advice or delay seeking it based on information from this app.

If you are experiencing a medical emergency, immediately contact emergency services or go to the nearest emergency room.

By using this app, you acknowledge that you understand these limitations and agree not to hold the developers liable for any health-related decisions you make based on the app's content.''';

  // Simple header builder
  Widget _buildSimpleHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Simple text builder
  Widget _buildSimpleText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
    );
  }

  // Simple Privacy Policy Content
  Widget _buildPrivacyPolicySimple() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleSubHeader('Who we are'),
        _buildTextWithLink(
          'Laennec AI Ltd is a UK-registered company developing educational health applications. Contact us at ',
          'jase@laennec.ai',
          'mailto:jase@laennec.ai',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Scope'),
        _buildSimpleText(
          'This policy explains how the COPD proof-of-concept app ("the App") processes information. It does not apply to any external websites linked from the App.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Data the App handles'),
        _buildBulletText(
          'Profile details you enter (name, date of birth, diagnosis status)',
        ),
        _buildBulletText(
          'Symptom check-ins (breathlessness scores, inhaler use, notes)',
        ),
        _buildBulletText(
          'Files you choose to attach (for example a photo of your COPD action plan)',
        ),
        _buildBulletText(
          'Optional feedback form data (name, e-mail, comments)',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Storage & Security'),
        _buildSimpleText(
          'All your data is stored securely on your device only. All profile and symptom data are saved only on your device in an encrypted app container. We do not transmit or back up these data to Laennec AI servers. Feedback-form messages are forwarded to our secure company e-mail and deleted after the query is resolved.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Your Rights'),
        _buildSimpleText(
          'You may request access to, rectification or erasure of your personal data, restrict processing or object to processing. Because most data are stored solely on your device, erasure can generally be completed by deleting the App.',
        ),
        _buildTextWithLink(
          'For feedback-form records email: ',
          'jase@laennec.ai',
          'mailto:jase@laennec.ai',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Security & Additional Information'),
        _buildBulletText(
          'Security: The App uses the device\'s standard encryption features. We recommend protecting your phone with a passcode or biometric lock.',
        ),
        _buildBulletText(
          'Children: The App is not intended for individuals under 16. We do not knowingly collect data from children.',
        ),
        _buildBulletText(
          'Retention: On-device data remain until you delete them or uninstall the App.',
        ),
        _buildBulletText(
          'Changes: We may update this policy at any time. Material changes will be sign-posted in-App and in the App Store description.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Contact Us'),
        _buildTextWithLink(
          'Questions about privacy may be sent to: ',
          'jase@laennec.ai',
          'mailto:jase@laennec.ai',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Sources'),
        _buildBulletWithLink(
          'GOLD 2025 Global Strategy report: ',
          'https://goldcopd.org/2025-gold-report/',
          'https://goldcopd.org/2025-gold-report/',
        ),
        _buildBulletWithLink(
          'NICE guideline NG115: ',
          'https://www.nice.org.uk/guidance/ng115',
          'https://www.nice.org.uk/guidance/ng115',
        ),
      ],
    );
  }

  // Simple Terms and Conditions Content
  Widget _buildTermsAndConditionsSimple() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleSubHeader('Acceptance'),
        _buildSimpleText(
          'By downloading or using the COPD proof-of-concept app ("the App") you agree to these Terms and Conditions ("Terms"). If you do not agree, do not use the App.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Educational Use Only'),
        _buildSimpleText(
          'This app is for educational and self-awareness purposes only. The App is provided for educational and self-awareness purposes. It is not a medical device and does not supply personalised medical advice, diagnosis, treatment plans or prescriptions.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Licence'),
        _buildSimpleText(
          'Laennec AI Ltd grants you a non-exclusive, revocable licence to use the App for personal, non-commercial purposes. All intellectual property rights remain with Laennec AI Ltd.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('User Responsibilities'),
        _buildSimpleText('You agree not to:'),
        _buildBulletText('Reverse-engineer, modify or distribute the App'),
        _buildBulletText('Upload unlawful content'),
        _buildBulletText(
          'Use the App in any manner that could damage, disable or overburden our infrastructure',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Limitation of Liability'),
        _buildSimpleText(
          'To the fullest extent permitted by law, Laennec AI Ltd shall not be liable for any loss or damage arising from use of, or inability to use, the App or from reliance on any content contained in it.',
        ),
        _buildSimpleText(
          'You agree to indemnify and hold Laennec AI Ltd harmless from any claim or demand arising out of your misuse of the App or breach of these Terms.',
        ),

        const SizedBox(height: 16),
        _buildSimpleSubHeader('Legal Information'),
        _buildBulletText(
          'Modifications: We may update the App and these Terms at any time. Continued use after an update constitutes acceptance of the revised Terms.',
        ),
        _buildBulletText(
          'Termination: We may terminate or suspend access to the App without notice if you breach these Terms. Sections 2, 3, 7 and 8 survive termination.',
        ),
        _buildBulletText(
          'Governing Law: These Terms are governed by and construed in accordance with the laws of England and Wales. Any disputes shall be subject to the exclusive jurisdiction of the English courts.',
        ),
      ],
    );
  }

  // Simple sub-header
  Widget _buildSimpleSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Simple bullet text
  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build text with clickable link
  Widget _buildTextWithLink(String prefix, String linkText, String url) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        children: [
          TextSpan(text: prefix),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _launchURL(url),
              child: Text(
                linkText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build bullet point with clickable link
  Widget _buildBulletWithLink(String prefix, String linkText, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(text: prefix),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _launchURL(url),
                      child: Text(
                        linkText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
