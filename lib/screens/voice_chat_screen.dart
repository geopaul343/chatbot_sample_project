import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_assistant/model/answer_option.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';

import 'package:laennec_ai_assistant/bloc/voice_bloc/question_bloc.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/question_event.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/question_state.dart';
import 'package:laennec_ai_assistant/widgets/flare_up_message_widget.dart';

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
      if (_quizCompleted) {
        context.read<QuestionBloc>().add(SendGeminiMessage(answer));
      } else {
        context.read<QuestionBloc>().add(SubmitAnswer(answer));
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
              _speak(state.questionText);
              _shouldListenAfterSpeech = !state.expectingCustomInput;
              setState(() {
                _quizCompleted = false;
              });
            } else if (state is QuizCompleted) {
              setState(() {
                _quizCompleted = true;
              });
              final lastMessage =
                  state.chatHistory.lastWhere(
                    (m) => m.containsKey('ai'),
                    orElse: () => {'ai': ''},
                  )['ai'];
              if (lastMessage != null && lastMessage.isNotEmpty) {
                _speak(lastMessage);
              }
            } else if (state is GeminiResponseLoaded) {
              _speak(state.response);
              _shouldListenAfterSpeech = true;
            } else if (state is GeminiError) {
              _speak(state.message);
            }
          },
          builder: (context, state) {
            List<Map<String, String>> chatHistory = [];
            List<AnswerOption> answerOptions = [];
            String? flareUpMessage;

            if (state is QuestionLoaded) {
              chatHistory = state.chatHistory;
              answerOptions = state.answerOptions;
              flareUpMessage = state.flareUpMessage;
            } else if (state is QuizCompleted) {
              chatHistory = state.chatHistory;
            } else if (state is GeminiLoading) {
              chatHistory = state.chatHistory;
            } else if (state is GeminiResponseLoaded) {
              chatHistory = state.chatHistory;
            } else if (state is GeminiError) {
              chatHistory = state.chatHistory;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = chatHistory.length - 1 - index;
                      final msg = chatHistory[reversedIndex];
                      final isSender = msg.containsKey('user');
                      final text = isSender ? msg['user']! : msg['ai']!;

                      return BubbleNormal(
                        text: text,
                        isSender: isSender,
                        color: isSender ? Colors.white : Colors.indigo.shade700,
                        textStyle: TextStyle(
                          color: isSender ? Colors.black87 : Colors.white,
                          fontSize: 16,
                        ),
                        tail: true,
                      );
                    },
                  ),
                ),
                if (flareUpMessage != null)
                  FlareUpMessageWidget(
                    message: flareUpMessage,
                    isEmergency: flareUpMessage.startsWith("Seek urgent help"),
                  ),
                if (answerOptions.isNotEmpty)
                  _buildAnswerOptions(answerOptions),
                if (state is GeminiLoading) const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _isListening
                      ? "Listening..."
                      : (_isSpeaking
                          ? "Speaking..."
                          : (_quizCompleted
                              ? "Ready for your command"
                              : "Tap to Speak")),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                GestureDetector(
                  onTapDown: (_) {
                    if (!_isListening) {
                      _startListening();
                    }
                  },
                  onTapUp: (_) {
                    if (_isListening) {
                      _stopListening();
                    }
                  },
                  onDoubleTap: () {
                    _flutterTts.stop();
                    setState(() => _isSpeaking = false);
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(List<AnswerOption> options) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children:
            options.map((option) {
              return Chip(
                label: Text(option.text),
                backgroundColor: Colors.blue.shade100,
              );
            }).toList(),
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
