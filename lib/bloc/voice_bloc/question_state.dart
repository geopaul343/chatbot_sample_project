import 'package:equatable/equatable.dart';
import 'package:laennec_ai_assistant/model/answer_option.dart';

/// Abstract base class for all Question Bloc states.
abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object> get props => [];
}

/// Initial state of the Question Bloc.
class QuestionInitial extends QuestionState {}

/// State representing a loaded question, including its text, options, and feedback.
class QuestionLoaded extends QuestionState {
  final int questionIndex; // Index of the current question.
  final String questionText; // The text of the current question.
  final List<AnswerOption>
  answerOptions; // List of predefined answer options for the current question.
  final String?
  feedbackMessage; // Optional message for user feedback (e.g., wrong answer).
  final List<Map<String, String>>
  chatHistory; // History of chat messages (user/AI)
  final bool isQuestionnaireComplete;
  final String? flareUpMessage;
  final List<String> userAnswers;
  final List<int> userScores;
  final bool expectingCustomInput;

  const QuestionLoaded({
    required this.questionIndex,
    required this.questionText,
    this.answerOptions = const [],
    this.feedbackMessage,
    this.chatHistory = const [], // Initialize as empty list
    this.isQuestionnaireComplete = false,
    this.flareUpMessage,
    this.userAnswers = const [],
    this.userScores = const [],
    this.expectingCustomInput = false,
  });

  @override
  List<Object> get props => [
    questionIndex,
    questionText,
    answerOptions,
    feedbackMessage ?? '',
    chatHistory,
    isQuestionnaireComplete,
    flareUpMessage ?? '',
    userAnswers,
    userScores,
    expectingCustomInput,
  ];

  QuestionLoaded copyWith({
    int? questionIndex,
    String? questionText,
    List<AnswerOption>? answerOptions,
    String? feedbackMessage,
    List<Map<String, String>>? chatHistory,
    bool? isQuestionnaireComplete,
    String? flareUpMessage,
    bool clearFlareUpMessage = false,
    List<String>? userAnswers,
    List<int>? userScores,
    bool? expectingCustomInput,
  }) {
    return QuestionLoaded(
      questionIndex: questionIndex ?? this.questionIndex,
      questionText: questionText ?? this.questionText,
      answerOptions: answerOptions ?? this.answerOptions,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      chatHistory: chatHistory ?? this.chatHistory,
      isQuestionnaireComplete:
          isQuestionnaireComplete ?? this.isQuestionnaireComplete,
      flareUpMessage:
          clearFlareUpMessage ? null : flareUpMessage ?? this.flareUpMessage,
      userAnswers: userAnswers ?? this.userAnswers,
      userScores: userScores ?? this.userScores,
      expectingCustomInput: expectingCustomInput ?? this.expectingCustomInput,
    );
  }
}

/// State indicating that all questions in the quiz have been completed.
class QuizCompleted extends QuestionState {
  final List<Map<String, String>> chatHistory; // Final chat history after quiz

  const QuizCompleted({this.chatHistory = const []});

  @override
  List<Object> get props => [chatHistory];
}

/// State representing a response from the Gemini AI in free chat mode.
class GeminiResponseLoaded extends QuestionState {
  final String response;
  final List<Map<String, String>>
  chatHistory; // Full chat history including Gemini response

  const GeminiResponseLoaded({
    required this.response,
    required this.chatHistory,
  });

  @override
  List<Object> get props => [response, chatHistory];
}

/// State representing an error during Gemini API call.
class GeminiError extends QuestionState {
  final String message;
  final List<Map<String, String>> chatHistory;

  const GeminiError({required this.message, required this.chatHistory});

  @override
  List<Object> get props => [message, chatHistory];
}

/// State indicating that the Gemini API call is in progress.
class GeminiLoading extends QuestionState {
  final List<Map<String, String>> chatHistory;

  const GeminiLoading({required this.chatHistory});

  @override
  List<Object> get props => [chatHistory];
}
