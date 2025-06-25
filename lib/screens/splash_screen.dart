import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_state.dart';
import 'package:laennec_ai_assistant/screens/medical_disclaimer_screen.dart';

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashBloc _splashBloc;

  @override
  void initState() {
    super.initState();
    _splashBloc = SplashBloc();
    _initializeApp();
  }

  @override
  void dispose() {
    _splashBloc.close();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    _splashBloc.add(const SplashStarted());

    // TODO: Version checking is temporarily disabled - uncomment when needed
    /*
    try {
      _splashBloc.add(const events.SplashUpdateStatus('Checking for updates...'));
      
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
          _splashBloc.add(const events.SplashUpdateStatus('Version up to date. Continuing...'));

          await Future.delayed(const Duration(milliseconds: 2000));

          if (mounted) {
            _splashBloc.add(events.SplashCompleted());
          }
        }
      }
    } catch (e) {
      print('Version check error: $e');
      _splashBloc.add(const events.SplashShowError('Version check failed. Continuing...'));

      // In case of error, continue anyway after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _splashBloc.add(events.SplashCompleted());
      }
    }
    */

    // Skip version check and go directly to disclaimer
    _splashBloc.add(const SplashUpdateStatus('Loading application...'));

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      _splashBloc.add(const SplashCompleted());
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
    return BlocProvider<SplashBloc>(
      create: (context) => _splashBloc,
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: BlocListener<SplashBloc, AppState>(
          listener: (context, state) {
            if (state is SplashComplete) {
              _navigateToDisclaimer();
            }
          },
          child: BlocBuilder<SplashBloc, AppState>(
            builder: (context, state) {
              String statusMessage = 'Loading...';
              bool showError = false;

              if (state is SplashLoading) {
                statusMessage = state.statusMessage;
              } else if (state is SplashError) {
                statusMessage = state.errorMessage;
                showError = true;
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      "assets/laennec_logo.png",
                      width: 100,
                      height: 100,
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!showError) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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
                            statusMessage,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
