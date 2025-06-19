import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:laennec_ai_health_assistant/questions/screen_questions.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Voice control
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  String _currentConversation = '';

  // Error and status tracking
  String _statusMessage = 'Initializing...';
  String _errorMessage = '';
  bool _hasError = false;
  bool _permissionGranted = false;
  bool _debugMode = false;

  // Questionnaire logic (same as chat screen)
  List<String> userAnswers = [];
  int currentQuestionIndex = 0;
  bool isQuestionnaireComplete = false;
  bool expectingCustomInput = false;
  String? expectedAnswerType;

  final List<List<String>> predefinedAnswers = [
    [
      "No breathlessness",
      "Slight breathlessness",
      "Moderate breathlessness",
      "Severe breathlessness",
      "Very severe breathlessness",
    ],
    ["Yes", "No"],
    List.generate(25, (index) => (index + 1).toString()), // 1-25 for puffs
    ["Yes", "No"],
    [], // Free text input for reason
    ["Yes", "No"],
    ["Green", "Yellow", "White", "Other"],
    ["Yes", "No"],
  ];

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeVoiceFeatures();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeVoiceFeatures() async {
    setState(() {
      _statusMessage = 'Requesting permissions...';
      _hasError = false;
    });

    try {
      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();

      if (permissionStatus != PermissionStatus.granted) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Microphone permission denied. Please enable it in settings.';
          _statusMessage = 'Permission denied';
        });
        return;
      }

      setState(() {
        _permissionGranted = true;
        _statusMessage = 'Initializing speech recognition...';
      });

      // Initialize speech recognition
      await _initSpeech();

      setState(() {
        _statusMessage = 'Initializing text-to-speech...';
      });

      // Initialize text-to-speech
      await _initTts();

      if (_speechEnabled) {
        setState(() {
          _statusMessage = 'Ready to start!';
          _hasError = false;
        });
        _startQuestionnaire();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Speech recognition not available on this device.';
          _statusMessage = 'Speech recognition unavailable';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Initialization failed: $e';
        _statusMessage = 'Initialization failed';
      });
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _isListening = false;
            _errorMessage = 'Speech error: ${error.errorMsg}';
            _statusMessage = 'Speech error occurred';
          });
          _pulseController.stop();
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          setState(() {
            _statusMessage = 'Speech status: $status';
          });

          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
            _pulseController.stop();
          }
        },
      );

      if (!_speechEnabled) {
        throw Exception('Speech recognition initialization failed');
      }

      // Check available locales
      final locales = await _speechToText.locales();
      print('Available locales: ${locales.length}');
    } catch (e) {
      print('Speech initialization error: $e');
      setState(() {
        _speechEnabled = false;
        _errorMessage = 'Speech initialization failed: $e';
      });
      throw e;
    }
  }

  Future<void> _initTts() async {
    try {
      // Set TTS settings
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set handlers
      _flutterTts.setStartHandler(() {
        print('TTS started');
        setState(() {
          _isSpeaking = true;
          _statusMessage = 'AI is speaking...';
        });
      });

      _flutterTts.setCompletionHandler(() {
        print('TTS completed');
        setState(() {
          _isSpeaking = false;
          _statusMessage = 'Waiting for your response...';
        });
        // Auto-restart listening after AI finishes speaking
        if (_speechEnabled && !_hasError) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!_isListening && mounted && !_isSpeaking) {
              _startListening();
            }
          });
        }
      });

      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        setState(() {
          _isSpeaking = false;
          _errorMessage = 'TTS Error: $msg';
          _statusMessage = 'Speech synthesis error';
        });
        // Try to restart listening even if TTS fails
        if (_speechEnabled && !_hasError) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_isListening && mounted && !_isSpeaking) {
              _startListening();
            }
          });
        }
      });

      // Test TTS capability
      await _flutterTts.speak("");
      await _flutterTts.stop();
    } catch (e) {
      print('TTS initialization error: $e');
      setState(() {
        _errorMessage = 'TTS initialization failed: $e';
      });
      throw e;
    }
  }

  void _startQuestionnaire() async {
    if (_hasError || !_speechEnabled) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _currentConversation +=
          "AI: Hello! I'm your Laennec AI assistant. I'll ask you a few questions about your health today. Let's start.\n\n";
      _statusMessage = 'Starting questionnaire...';
    });

    await _speakAndWait(
      "Hello! I'm your Laennec AI assistant. I'll ask you a few questions about your health today. Let's start.",
    );

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentConversation += "AI: ${screenQuestions[0]}\n\n";
    });

    await _speakAndWait(screenQuestions[0]);
    _speakAnswerOptions(0);
  }

  Future<void> _speakAndWait(String text) async {
    if (_hasError) return;

    try {
      await _flutterTts.speak(text);
      // Wait for the speech to start
      await Future.delayed(const Duration(milliseconds: 300));
      // Wait for the speech to complete with timeout
      int waitCount = 0;
      while (_isSpeaking && waitCount < 100) {
        // 10 second timeout
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }

      if (waitCount >= 100) {
        print('TTS timeout - forcing stop');
        await _flutterTts.stop();
        setState(() {
          _isSpeaking = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Speak and wait error: $e');
      setState(() {
        _errorMessage = 'Speaking failed: $e';
        _isSpeaking = false;
      });
    }
  }

  void _speakAnswerOptions(int questionIndex) {
    if (_hasError || questionIndex >= predefinedAnswers.length) return;

    if (predefinedAnswers[questionIndex].isNotEmpty) {
      String options;

      // Special handling for puffs question (index 2)
      if (questionIndex == 2) {
        options =
            "Please choose a number from 1 to 25 for the number of puffs.";
      } else {
        // Normal handling for other questions
        options = "Your options are: ";
        for (int i = 0; i < predefinedAnswers[questionIndex].length; i++) {
          if (i == predefinedAnswers[questionIndex].length - 1) {
            options += "or ${predefinedAnswers[questionIndex][i]}";
          } else if (i == predefinedAnswers[questionIndex].length - 2) {
            options += "${predefinedAnswers[questionIndex][i]} ";
          } else {
            options += "${predefinedAnswers[questionIndex][i]}, ";
          }
        }
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_hasError) {
          _speak(options);
        }
      });
    }
  }

  void _startListening() async {
    if (!_speechEnabled || _hasError || _isSpeaking) {
      print(
        'Cannot start listening: speechEnabled=$_speechEnabled, hasError=$_hasError, isSpeaking=$_isSpeaking',
      );
      return;
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      );

      setState(() {
        _isListening = true;
        _statusMessage = 'Listening... Speak now';
        _lastWords = '';
      });

      _pulseController.repeat(reverse: true);
      print('Started listening successfully');
    } catch (e) {
      print('Start listening error: $e');
      setState(() {
        _errorMessage = 'Failed to start listening: $e';
        _statusMessage = 'Listening failed';
        _isListening = false;
      });
    }
  }

  void _stopListening() async {
    try {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
        _statusMessage = 'Stopped listening';
      });
      _pulseController.stop();
      print('Stopped listening');
    } catch (e) {
      print('Stop listening error: $e');
      setState(() {
        _isListening = false;
        _errorMessage = 'Failed to stop listening: $e';
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _statusMessage = result.finalResult ? 'Processing...' : 'Listening...';
    });

    print(
      'Speech result: "${result.recognizedWords}" (final: ${result.finalResult})',
    );

    if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
      _processUserInput(_lastWords);
    }
  }

  void _processUserInput(String userInput) {
    if (userInput.trim().isEmpty) return;

    setState(() {
      _currentConversation += "You: $userInput\n\n";
    });

    // Handle meta-questions first (repeat, what did you say, etc.)
    if (_handleMetaQuestions(userInput.toLowerCase().trim())) {
      return;
    }

    if (isQuestionnaireComplete) {
      _handleFreeChat(userInput);
      return;
    }

    _handleQuestionnaireAnswer(userInput);
  }

  bool _handleMetaQuestions(String userInput) {
    // Check for requests to repeat the question
    if (userInput.contains("repeat") ||
        userInput.contains("again") ||
        userInput.contains("say that again") ||
        userInput.contains("what did you say") ||
        userInput.contains("didn't hear") ||
        userInput.contains("could you please") ||
        userInput.contains("can you repeat")) {
      setState(() {
        _currentConversation += "AI: Of course! Let me repeat that.\n\n";
      });

      _speak("Of course! Let me repeat that.");

      // Wait for TTS to complete, then repeat current question
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (isQuestionnaireComplete) {
          _speak(
            "The questionnaire is complete. You can ask me anything about your health.",
          );
        } else {
          _speak(screenQuestions[currentQuestionIndex]);
          _speakAnswerOptions(currentQuestionIndex);
        }
      });

      return true;
    }

    // Check for help requests
    if (userInput.contains("help") ||
        userInput.contains("what are my options") ||
        userInput.contains("what can i say") ||
        userInput.contains("options")) {
      setState(() {
        _currentConversation += "AI: Let me tell you your options.\n\n";
      });

      _speak("Let me tell you your options.");

      Future.delayed(const Duration(milliseconds: 1500), () {
        _speakAnswerOptions(currentQuestionIndex);
      });

      return true;
    }

    // Check for requests to go back
    if (userInput.contains("go back") ||
        userInput.contains("previous question") ||
        userInput.contains("last question")) {
      setState(() {
        _currentConversation +=
            "AI: I'm sorry, but I can't go back to previous questions. Let's continue with the current question.\n\n";
      });

      _speak(
        "I'm sorry, but I can't go back to previous questions. Let's continue with the current question.",
      );

      Future.delayed(const Duration(milliseconds: 3000), () {
        _speak(screenQuestions[currentQuestionIndex]);
        _speakAnswerOptions(currentQuestionIndex);
      });

      return true;
    }

    return false;
  }

  void _handleQuestionnaireAnswer(String userInput) async {
    String cleanInput = userInput.toLowerCase().trim();

    // Special handling for question 4 (free text input)
    if (expectingCustomInput && currentQuestionIndex == 4) {
      userAnswers.add(userInput);
      setState(() {
        _currentConversation += "AI: Thank you for explaining.\n\n";
        expectingCustomInput = false;
      });

      await _speakAndWait("Thank you for explaining.");
      _moveToNextQuestion();
      return;
    }

    // Validate answer against predefined options
    List<String> currentOptions = predefinedAnswers[currentQuestionIndex];
    String? matchedAnswer = _findMatchingAnswer(cleanInput, currentOptions);

    if (matchedAnswer != null) {
      userAnswers.add(matchedAnswer);
      setState(() {
        _currentConversation += "AI: Got it, $matchedAnswer.\n\n";
      });

      await _speakAndWait("Got it, $matchedAnswer.");

      // Special handling for maintenance inhaler question (index 3)
      if (currentQuestionIndex == 3) {
        if (matchedAnswer.toLowerCase() == "no") {
          _handleMaintenanceInhalerNo();
        } else {
          _handleMaintenanceInhalerYes();
        }
      } else {
        _moveToNextQuestion();
      }
    } else {
      // Invalid answer - ask to choose from options
      setState(() {
        _currentConversation +=
            "AI: That's not an expected answer. Please choose from the available options.\n\n";
      });

      String responseText =
          "That's not an expected answer. Please choose from the available options. ";
      await _speakAndWait(responseText);
      _speakAnswerOptions(currentQuestionIndex);
    }
  }

  String? _findMatchingAnswer(String userInput, List<String> options) {
    // Exact match first
    for (String option in options) {
      if (userInput == option.toLowerCase()) {
        return option;
      }
    }

    // Partial match for common variations
    for (String option in options) {
      String optionLower = option.toLowerCase();

      // Handle yes/no variations
      if (optionLower == "yes" &&
          (userInput.contains("yes") ||
              userInput.contains("yeah") ||
              userInput.contains("yep"))) {
        return option;
      }
      if (optionLower == "no" &&
          (userInput.contains("no") ||
              userInput.contains("nope") ||
              userInput.contains("nah"))) {
        return option;
      }

      // Handle breathlessness levels
      if (optionLower.contains("no breathlessness") &&
          (userInput.contains("no breathless") ||
              userInput.contains("not breathless"))) {
        return option;
      }
      if (optionLower.contains("slight") && userInput.contains("slight")) {
        return option;
      }
      if (optionLower.contains("moderate") && userInput.contains("moderate")) {
        return option;
      }
      if (optionLower.contains("severe breathlessness") &&
          userInput.contains("severe") &&
          !userInput.contains("very")) {
        return option;
      }
      if (optionLower.contains("very severe") &&
          userInput.contains("very severe")) {
        return option;
      }

      // Handle colors
      if (optionLower.contains("green") && userInput.contains("green")) {
        return option;
      }
      if (optionLower.contains("yellow") && userInput.contains("yellow")) {
        return option;
      }
      if (optionLower.contains("white") && userInput.contains("white")) {
        return option;
      }
      if (optionLower.contains("other") &&
          (userInput.contains("other") || userInput.contains("different"))) {
        return option;
      }

      // Handle numbers for puffs
      if (RegExp(r'^\d+$').hasMatch(option.trim())) {
        RegExp numberRegex = RegExp(r'\b(\d+)\b');
        Match? match = numberRegex.firstMatch(userInput);
        if (match != null) {
          String extractedNumber = match.group(1)!;
          if (extractedNumber == option) {
            return option;
          }
        }
      }
    }

    return null;
  }

  void _handleMaintenanceInhalerNo() async {
    setState(() {
      currentQuestionIndex = 4;
      expectingCustomInput = true;
      _currentConversation += "AI: ${screenQuestions[4]}\n\n";
    });

    await _speakAndWait(screenQuestions[4]);
  }

  void _handleMaintenanceInhalerYes() {
    // Skip question 4 and go to question 5
    userAnswers.add("N/A (maintenance inhaler was taken)");
    currentQuestionIndex = 5;
    _askNextQuestion();
  }

  void _moveToNextQuestion() {
    currentQuestionIndex++;
    if (currentQuestionIndex >= screenQuestions.length) {
      _completeQuestionnaire();
    } else {
      _askNextQuestion();
    }
  }

  void _askNextQuestion() async {
    if (currentQuestionIndex < screenQuestions.length) {
      setState(() {
        _currentConversation +=
            "AI: ${screenQuestions[currentQuestionIndex]}\n\n";
      });

      await _speakAndWait(screenQuestions[currentQuestionIndex]);
      _speakAnswerOptions(currentQuestionIndex);
    } else {
      _completeQuestionnaire();
    }
  }

  void _completeQuestionnaire() {
    setState(() {
      isQuestionnaireComplete = true;
      _currentConversation +=
          "AI: Thank you for your responses! Here's a summary:\n\n";
    });

    String summary = _formatAllAnswers();
    setState(() {
      _currentConversation += summary + "\n\n";
      _currentConversation +=
          "AI: The questionnaire is complete. You can now ask me anything about your health.\n\n";
    });

    _speak(
      "Thank you for your responses! The questionnaire is complete. You can now ask me anything about your health.",
    );
  }

  String _formatAllAnswers() {
    final List<String> formattedAnswers = [];
    for (int i = 0; i < userAnswers.length && i < screenQuestions.length; i++) {
      formattedAnswers.add("Question ${i + 1}: ${screenQuestions[i]}");
      formattedAnswers.add("Answer: ${userAnswers[i]}");
      formattedAnswers.add("");
    }
    return formattedAnswers.join('\n');
  }

  void _handleFreeChat(String userInput) {
    // Simple health-related responses for free chat
    String response = _generateHealthResponse(userInput);

    setState(() {
      _currentConversation += "AI: $response\n\n";
    });

    _speak(response);
  }

  String _generateHealthResponse(String userInput) {
    String input = userInput.toLowerCase();

    if (input.contains('hello') || input.contains('hi')) {
      return "Hello! How can I help you with your health concerns today?";
    } else if (input.contains('pain') || input.contains('hurt')) {
      return "I understand you're experiencing pain. Can you describe where it hurts and how long you've been feeling this way?";
    } else if (input.contains('cough') || input.contains('throat')) {
      return "A cough can have various causes. How long have you had this cough? Is it dry or productive?";
    } else if (input.contains('fever') || input.contains('temperature')) {
      return "Fever can be a sign of infection. Have you taken your temperature? Any other symptoms?";
    } else if (input.contains('thank') || input.contains('thanks')) {
      return "You're welcome! Is there anything else I can help you with regarding your health?";
    } else if (input.contains('bye') || input.contains('goodbye')) {
      return "Take care! Remember to consult with a healthcare professional for serious concerns.";
    } else {
      return "I understand your concern. Can you provide more details about your symptoms so I can better assist you?";
    }
  }

  void _speak(String text) async {
    if (_hasError) return;

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Speak error: $e');
      setState(() {
        _errorMessage = 'Failed to speak: $e';
      });
    }
  }

  void _restartVoiceChat() {
    setState(() {
      _lastWords = '';
      _currentConversation = '';
      userAnswers.clear();
      currentQuestionIndex = 0;
      isQuestionnaireComplete = false;
      expectingCustomInput = false;
      _hasError = false;
      _errorMessage = '';
      _statusMessage = 'Restarting...';
    });
    _initializeVoiceFeatures();
  }

  void _closeVoiceChat() {
    _stopListening();
    _flutterTts.stop();
    Navigator.of(context).pop();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
            'This feature requires microphone access to work. Please enable microphone permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 400;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isSmallScreen ? 60 : 70,
        title: Text(
          "Laennec AI Voice Assistant",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : (isLargeScreen ? 20 : 18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Voice Status Indicator
            Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Animated Microphone Icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: isSmallScreen ? 100 : 120,
                          height: isSmallScreen ? 100 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _isListening
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : _isSpeaking
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.indigo.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                            border: Border.all(
                              color:
                                  _isListening
                                      ? Colors.red
                                      : _isSpeaking
                                      ? Colors.green
                                      : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.mic
                                : _isSpeaking
                                ? Icons.volume_up
                                : Icons.mic_off,
                            size: isSmallScreen ? 50 : 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  // Status Text
                  if (_hasError)
                    Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: isSmallScreen ? 24 : 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (!_permissionGranted)
                          ElevatedButton(
                            onPressed: _showPermissionDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              'Fix Permissions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    )
                  else if (_isListening)
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'Listening...',
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                    )
                  else if (_isSpeaking)
                    Text(
                      'Laennec AI is speaking...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isQuestionnaireComplete
                              ? 'Complete - Ask me anything!'
                              : 'Answer the health questions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Conversation History
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Question and options content
                    if (!isQuestionnaireComplete &&
                        currentQuestionIndex < screenQuestions.length)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Question:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              screenQuestions[currentQuestionIndex],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Answer Options Display (compact for puffs question)
                    if (!isQuestionnaireComplete &&
                        currentQuestionIndex < predefinedAnswers.length &&
                        predefinedAnswers[currentQuestionIndex].isNotEmpty &&
                        !expectingCustomInput)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Answer Options:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Special handling for puffs question (don't show all 25 numbers)
                            if (currentQuestionIndex == 2)
                              Row(
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: Colors.green.shade300,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Say any number from 1 to 25',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 13 : 15,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              ...predefinedAnswers[currentQuestionIndex]
                                  .take(5)
                                  .map(
                                    (option) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.mic,
                                            color: Colors.green.shade300,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    isSmallScreen ? 12 : 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            // Show "..." if there are more options
                            if (currentQuestionIndex != 2 &&
                                predefinedAnswers[currentQuestionIndex].length >
                                    5)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '... and more options',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isSmallScreen ? 11 : 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Free Text Input Indicator
                    if (expectingCustomInput && currentQuestionIndex == 4)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Free Text Answer:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.keyboard_voice,
                                  color: Colors.blue.shade300,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Speak your reason freely...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 13 : 15,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Last recognized words
                    if (_lastWords.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.purple.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You said:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"$_lastWords"',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Debug Panel (if enabled)
                    if (_debugMode)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Info:',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Speech Enabled: $_speechEnabled\n'
                              'Permission Granted: $_permissionGranted\n'
                              'Is Listening: $_isListening\n'
                              'Is Speaking: $_isSpeaking\n'
                              'Has Error: $_hasError\n'
                              'Status: $_statusMessage',
                              style: TextStyle(
                                color: Colors.orange.shade200,
                                fontSize: isSmallScreen ? 10 : 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Conversation History
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(15),
                      constraints: BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Conversation Log:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _debugMode = !_debugMode,
                                    ),
                                child: Icon(
                                  _debugMode
                                      ? Icons.bug_report
                                      : Icons.info_outline,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentConversation.isEmpty
                                ? 'Starting health questionnaire...'
                                : _currentConversation,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 11 : 13,
                              height: 1.4,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Close Chat Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _closeVoiceChat,
                icon: const Icon(Icons.close, color: Colors.white),
                label: Text(
                  'Close Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            // Microphone Button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _hasError
                        ? Colors.grey
                        : _isListening
                        ? Colors.red
                        : Colors.green,
              ),
              child: IconButton(
                onPressed:
                    _hasError
                        ? null
                        : (_isListening ? _stopListening : _startListening),
                icon: Icon(
                  _hasError
                      ? Icons.mic_none
                      : _isListening
                      ? Icons.mic_off
                      : Icons.mic,
                  color: _hasError ? Colors.white54 : Colors.white,
                  size: 30,
                ),
                padding: const EdgeInsets.all(15),
              ),
            ),

            const SizedBox(width: 15),

            // Restart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _restartVoiceChat,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Restart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
