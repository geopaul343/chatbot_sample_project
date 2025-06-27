import 'package:equatable/equatable.dart';

import 'package:laennec_ai_assistant/model/answer_option.dart';
import 'package:laennec_ai_assistant/model/message.dart';

// Base app state for splash functionality
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

// Splash states
class SplashInitial extends AppState {
  const SplashInitial();
}

class SplashLoading extends AppState {
  final String statusMessage;

  const SplashLoading(this.statusMessage);

  @override
  List<Object> get props => [statusMessage];
}

class SplashError extends AppState {
  final String errorMessage;

  const SplashError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class SplashComplete extends AppState {
  const SplashComplete();
}

// Chat state (existing functionality)
class ChatState extends Equatable {
  final List<Message> messages;
  final bool isTyping;
  final bool isQuestionnaireComplete;
  final bool showAnswerOptions;
  final int currentQuestionIndex;
  final String? selectedAnswer;
  final List<AnswerOption> answers;
  final List<String> userAnswers;
  final List<int> userScores;
  final bool expectingCustomInput;
  final String? flareUpMessage;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isQuestionnaireComplete = false,
    this.showAnswerOptions = false,
    this.currentQuestionIndex = 0,
    this.selectedAnswer,
    this.answers = const [],
    this.userAnswers = const [],
    this.userScores = const [],
    this.expectingCustomInput = false,
    this.flareUpMessage,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isTyping,
    bool? isQuestionnaireComplete,
    bool? showAnswerOptions,
    int? currentQuestionIndex,
    String? selectedAnswer,
    List<AnswerOption>? answers,
    List<String>? userAnswers,
    List<int>? userScores,
    bool? expectingCustomInput,
    bool clearSelectedAnswer = false,
    String? flareUpMessage,
    bool clearFlareUpMessage = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isQuestionnaireComplete:
          isQuestionnaireComplete ?? this.isQuestionnaireComplete,
      showAnswerOptions: showAnswerOptions ?? this.showAnswerOptions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswer:
          clearSelectedAnswer ? null : selectedAnswer ?? this.selectedAnswer,
      answers: answers ?? this.answers,
      userAnswers: userAnswers ?? this.userAnswers,
      userScores: userScores ?? this.userScores,
      expectingCustomInput: expectingCustomInput ?? this.expectingCustomInput,
      flareUpMessage:
          clearFlareUpMessage ? null : flareUpMessage ?? this.flareUpMessage,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isTyping,
    isQuestionnaireComplete,
    showAnswerOptions,
    currentQuestionIndex,
    selectedAnswer,
    answers,
    userAnswers,
    userScores,
    expectingCustomInput,
    flareUpMessage,
  ];
}
