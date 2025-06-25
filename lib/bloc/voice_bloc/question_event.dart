import 'package:equatable/equatable.dart';

/// Abstract base class for all Question Bloc events.
abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object> get props => [];
}

/// Event to load the next question or the initial question.
class LoadQuestion extends QuestionEvent {
  const LoadQuestion();
}

/// Event to submit the user's answer to the current question.
class SubmitAnswer extends QuestionEvent {
  final String answer; // The answer submitted by the user.
  const SubmitAnswer(this.answer);

  @override
  List<Object> get props => [answer];
}

/// Event to restart the entire quiz from the beginning.
class RestartQuiz extends QuestionEvent {
  const RestartQuiz();
}

/// Event to send a free-form message to the Gemini AI after the quiz.
class SendGeminiMessage extends QuestionEvent {
  final String message;
  const SendGeminiMessage(this.message);

  @override
  List<Object> get props => [message];
}
