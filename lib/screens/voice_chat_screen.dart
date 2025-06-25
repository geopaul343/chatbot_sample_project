import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';

import 'package:laennec_ai_assistant/bloc/voice_bloc/question_bloc.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/question_event.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/question_state.dart';

class VoiceChatScreen extends StatelessWidget {
  const VoiceChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestionBloc()..add(const LoadQuestion()),
      child: const VoiceChatView(),
    );
  }
}

class VoiceChatView extends StatefulWidget {
  const VoiceChatView({super.key});

  @override
  State<VoiceChatView> createState() => _VoiceChatViewState();
}

class _VoiceChatViewState extends State<VoiceChatView> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  bool _isSpeaking = false;
  bool _quizCompleted = false;

  bool _shouldListenAfterSpeech = false;
  List<Map<String, String>> _displayChatHistory = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    bool hasPermission = await _speechToText.hasPermission;
    if (!hasPermission) {
      hasPermission = await _speechToText.initialize(
        onStatus: (status) {
          setState(() {
            _isListening = status == 'listening';
          });
        },
        onError: (errorNotification) {
          debugPrint('Speech recognition error: ${errorNotification.errorMsg}');
          setState(() => _isListening = false);
        },
      );
    }

    if (hasPermission) {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          setState(() {
            _isListening = status == 'listening';
          });
          if (status == 'notListening' && !_isSpeaking && _lastWords.isEmpty) {
            _handleSpeechRecognitionTimeout();
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech recognition error: ${errorNotification.errorMsg}');
          setState(() => _isListening = false);
          _speakAndRestartListeningOnError();
        },
      );
    } else {
      debugPrint('Microphone permission not granted.');
      _speak(
        "Microphone permission is required for voice input. Please grant it in settings.",
      );
    }
    setState(() {});
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
      if (_shouldListenAfterSpeech && _speechEnabled) {
        _startListening();
      }
    });
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        debugPrint("TTS Error: $msg");
        _isSpeaking = false;
      });
    });
    _flutterTts.setLanguage("en-US");
  }

  void _handleSpeechRecognitionTimeout() {
    if (_lastWords.isEmpty && !_isSpeaking) {
      _speakAndRestartListeningOnError();
    }
  }

  Future<void> _speakAndRestartListeningOnError() async {
    _shouldListenAfterSpeech = true;
    await _speak(
      "I couldn't understand, could you please repeat this for one more time?",
    );
  }

  void _startListening() async {
    if (!_isSpeaking && _speechEnabled && !_isListening) {
      setState(() {
        _isListening = true;
        _lastWords = '';
      });
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
          });
          if (result.finalResult) {
            _stopListening();
            _submitAnswer(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(partialResults: false),
        onSoundLevelChange: (level) {},
      );
    } else if (!_speechEnabled) {
      debugPrint(
        'Speech not enabled. Attempting to re-initialize speech recognition.',
      );
      _speak(
        "Speech recognition is not enabled. Please check microphone permissions in app settings.",
      );
      _initSpeech();
    }
  }

  void _stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = true;
    });
    await _flutterTts.speak(text);
  }

  void _submitAnswer(String answer) {
    if (answer.isNotEmpty) {
      setState(() {
        _displayChatHistory.add({'role': 'user', 'text': answer});
        _lastWords = '';
      });
      _scrollToBottom();

      if (!_quizCompleted) {
        context.read<QuestionBloc>().add(SubmitAnswer(answer));
      } else {
        context.read<QuestionBloc>().add(SendGeminiMessage(answer));
      }
    } else {
      _speakAndRestartListeningOnError();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 400;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isSmallScreen ? 60 : 70,
        title: Text(
          "Voice Assistant",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : (isLargeScreen ? 20 : 18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<QuestionBloc>().add(const RestartQuiz());
              setState(() {
                _quizCompleted = false;
                _displayChatHistory.clear();
              });
            },
            tooltip: 'Restart Quiz',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<QuestionBloc, QuestionState>(
          listener: (context, state) {
            if (state is QuestionLoaded) {
              _displayChatHistory = List.from(state.chatHistory);
              _shouldListenAfterSpeech = true;
              _speak(state.questionText);
              _scrollToBottom();
            } else if (state is QuizCompleted) {
              _quizCompleted = true;
              _displayChatHistory = List.from(state.chatHistory);
              _shouldListenAfterSpeech = true;
              _speak("Quiz completed! Now you can ask me anything.");
              _scrollToBottom();
            } else if (state is GeminiResponseLoaded) {
              _displayChatHistory = List.from(state.chatHistory);
              _shouldListenAfterSpeech = true;
              _speak(state.response);
              _scrollToBottom();
            } else if (state is GeminiError) {
              _displayChatHistory = List.from(state.chatHistory);
              _shouldListenAfterSpeech = true;
              _speak("I apologize, but there was an error: ${state.message}");
              _scrollToBottom();
            } else if (state is GeminiLoading) {
              _displayChatHistory = List.from(state.chatHistory);
              _shouldListenAfterSpeech = false;
              _scrollToBottom();
            } else if (state is QuestionInitial) {
              _shouldListenAfterSpeech = false;
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.only(
                      bottom: 8.0,
                      left: screenWidth * 0.02,
                      right: screenWidth * 0.02,
                    ),
                    itemCount: _displayChatHistory.length,
                    itemBuilder: (context, index) {
                      final message =
                          _displayChatHistory[_displayChatHistory.length -
                              1 -
                              index];
                      final isUser = message['role'] == 'user';
                      return BubbleNormal(
                        text: message['text'] ?? '',
                        isSender: isUser,
                        color: isUser ? Colors.white : Colors.indigo.shade700,
                        textStyle: TextStyle(
                          color: isUser ? Colors.black87 : Colors.white,
                          fontSize:
                              isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
                        ),
                        tail: true,
                        sent: isUser,
                      );
                    },
                  ),
                ),

                // AI Thinking/Speaking indicator (matching chat screen style exactly)
                if (_isSpeaking || (state is GeminiLoading))
                  Padding(
                    padding: EdgeInsets.only(
                      left: 0,
                      bottom: 8.0,
                      top: 8.0,
                      right: screenWidth * 0.7,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: isSmallScreen ? 8.0 : 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade700,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            _isSpeaking ? 'Speaking...' : '• • •',
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  isSmallScreen
                                      ? 13.0
                                      : (isLargeScreen ? 17.0 : 15.0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: _isSpeaking ? 1.0 : 4.0,
                            ),
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        isRepeatingAnimation: true,
                        repeatForever: true,
                      ),
                    ),
                  ),

                // Answer options (matching chat screen button style)
                if (state is QuestionLoaded && state.answerOptions.isNotEmpty)
                  _buildAnswerOptions(
                    context,
                    state,
                    screenWidth,
                    isSmallScreen,
                    isLargeScreen,
                  ),

                // Voice control interface (matching chat screen input style)
                _buildVoiceControls(
                  context,
                  state,
                  screenWidth,
                  isSmallScreen,
                  isLargeScreen,
                ),

                const SizedBox(height: 25),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(
    BuildContext context,
    QuestionLoaded state,
    double screenWidth,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: 8.0,
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children:
            state.answerOptions.map((option) {
              return GestureDetector(
                onTap: () => _submitAnswer(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.indigo.shade300,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontSize: isSmallScreen ? 13 : (isLargeScreen ? 16 : 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildVoiceControls(
    BuildContext context,
    QuestionState state,
    double screenWidth,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    final bool isEnabled = !_isSpeaking && state is! GeminiLoading;

    String getStatusText() {
      if (!_speechEnabled) {
        return 'Initializing voice features...';
      } else if (_isSpeaking) {
        return 'Speaking...';
      } else if (_isListening) {
        return 'Listening... Speak your answer';
      } else if (state is QuestionLoaded) {
        return 'Question ${state.questionIndex + 1} - Tap microphone to answer';
      } else if (state is QuizCompleted) {
        return 'Quiz completed! Ask me anything';
      } else if (state is GeminiLoading) {
        return 'Processing your question...';
      } else {
        return 'Ready for voice interaction';
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color:
            _isSpeaking || _isListening
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Status text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              getStatusText(),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Current words being recognized
          if (_isListening && _lastWords.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade700.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '"$_lastWords"',
                      style: TextStyle(
                        fontSize:
                            isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

          // Voice control buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Main microphone button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          _isListening
                              ? [Colors.red.shade400, Colors.red.shade600]
                              : [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed:
                        isEnabled
                            ? (_isListening ? _stopListening : _startListening)
                            : null,
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: isSmallScreen ? 28 : (isLargeScreen ? 36 : 32),
                    ),
                    iconSize: isSmallScreen ? 56 : (isLargeScreen ? 72 : 64),
                  ),
                ),

                // Repeat question button (only during quiz)
                if (state is QuestionLoaded)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _speak(state.questionText),
                      icon: Icon(
                        Icons.replay,
                        color: Colors.white,
                        size: isSmallScreen ? 24 : (isLargeScreen ? 32 : 28),
                      ),
                      iconSize: isSmallScreen ? 48 : (isLargeScreen ? 64 : 56),
                    ),
                  ),

                // Free chat mode indicator (after quiz completion)
                if (state is QuizCompleted ||
                    state is GeminiResponseLoaded ||
                    state is GeminiError)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed:
                          isEnabled
                              ? (_isListening
                                  ? _stopListening
                                  : _startListening)
                              : null,
                      icon: Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: isSmallScreen ? 24 : (isLargeScreen ? 32 : 28),
                      ),
                      iconSize: isSmallScreen ? 48 : (isLargeScreen ? 64 : 56),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }
}
