import 'package:equatable/equatable.dart';

/// Abstract base class for all Question Bloc states.
abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object> get props => [];
}

/// Initial state when the quiz starts.
class QuestionInitial extends QuestionState {
  const QuestionInitial();
}

/// State when a question is loaded and ready to be answered.
class QuestionLoaded extends QuestionState {
  final int questionIndex;
  final String questionText;
  final List<String> answerOptions;
  final String? feedbackMessage;
  final List<Map<String, String>> chatHistory;

  const QuestionLoaded({
    required this.questionIndex,
    required this.questionText,
    required this.answerOptions,
    this.feedbackMessage,
    required this.chatHistory,
  });

  @override
  List<Object> get props => [
    questionIndex,
    questionText,
    answerOptions,
    feedbackMessage ?? '',
    chatHistory,
  ];
}

/// State when all quiz questions have been completed.
class QuizCompleted extends QuestionState {
  final List<Map<String, String>> chatHistory;

  const QuizCompleted({required this.chatHistory});

  @override
  List<Object> get props => [chatHistory];
}

/// State when loading a response from Gemini AI.
class GeminiLoading extends QuestionState {
  final List<Map<String, String>> chatHistory;

  const GeminiLoading({required this.chatHistory});

  @override
  List<Object> get props => [chatHistory];
}

/// State when a response is received from Gemini AI.
class GeminiResponseLoaded extends QuestionState {
  final String response;
  final List<Map<String, String>> chatHistory;

  const GeminiResponseLoaded({
    required this.response,
    required this.chatHistory,
  });

  @override
  List<Object> get props => [response, chatHistory];
}

/// State when an error occurs with Gemini AI.
class GeminiError extends QuestionState {
  final String message;
  final List<Map<String, String>> chatHistory;

  const GeminiError({required this.message, required this.chatHistory});

  @override
  List<Object> get props => [message, chatHistory];
}
