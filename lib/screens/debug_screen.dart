import 'package:flutter/material.dart';

import 'package:laennec_ai_assistant/screens/medical_disclaimer_screen.dart';
import 'package:laennec_ai_assistant/utils/first_launch_checker.dart';
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _hasAcceptedPrivacy = false;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final hasAccepted = await FirstLaunchChecker.hasAcceptedPrivacyPolicy();
    final isFirst = await FirstLaunchChecker.isFirstLaunch();

    setState(() {
      _hasAcceptedPrivacy = hasAccepted;
      _isFirstLaunch = isFirst;
    });
  }

  Future<void> _resetPreferences() async {
    await FirstLaunchChecker.resetPreferences();
    await _loadStatus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy preferences reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showPrivacyPolicy() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MedicalDisclaimerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Settings'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Policy Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _hasAcceptedPrivacy
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              _hasAcceptedPrivacy ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Policy Accepted: ${_hasAcceptedPrivacy ? "Yes" : "No"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isFirstLaunch ? Icons.new_releases : Icons.replay,
                          color: _isFirstLaunch ? Colors.orange : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Is First Launch: ${_isFirstLaunch ? "Yes" : "No"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resetPreferences,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Privacy Preferences'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showPrivacyPolicy,
                        icon: const Icon(Icons.policy),
                        label: const Text('View Privacy Policy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Test:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Reset privacy preferences\n'
                      '2. Close and restart the app\n'
                      '3. Privacy policy should appear\n'
                      '4. Accept or disagree to test behavior',
                      style: TextStyle(fontSize: 14),
                    ),
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
