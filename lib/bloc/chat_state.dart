import 'package:equatable/equatable.dart';

import 'package:laennec_ai_health_assistant/model/message.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final bool isTyping;
  final bool isQuestionnaireComplete;
  final bool showAnswerOptions;
  final int currentQuestionIndex;
  final String? selectedAnswer;
  final List<String> answers;
  final List<String> userAnswers;
  final bool expectingCustomInput;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isQuestionnaireComplete = false,
    this.showAnswerOptions = false,
    this.currentQuestionIndex = 0,
    this.selectedAnswer,
    this.answers = const [],
    this.userAnswers = const [],
    this.expectingCustomInput = false,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isTyping,
    bool? isQuestionnaireComplete,
    bool? showAnswerOptions,
    int? currentQuestionIndex,
    String? selectedAnswer,
    List<String>? answers,
    List<String>? userAnswers,
    bool? expectingCustomInput,
    bool clearSelectedAnswer = false,
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
      expectingCustomInput: expectingCustomInput ?? this.expectingCustomInput,
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
    expectingCustomInput,
  ];
}
