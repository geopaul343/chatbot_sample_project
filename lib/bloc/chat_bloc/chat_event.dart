import 'package:equatable/equatable.dart';

// Base app event for splash functionality
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

// Splash events
class SplashStarted extends AppEvent {
  const SplashStarted();
}

class SplashUpdateStatus extends AppEvent {
  final String statusMessage;

  const SplashUpdateStatus(this.statusMessage);

  @override
  List<Object> get props => [statusMessage];
}

class SplashShowError extends AppEvent {
  final String errorMessage;

  const SplashShowError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class SplashCompleted extends AppEvent {
  const SplashCompleted();
}

// Chat events (existing functionality)
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

/// Event to signal the start of the questionnaire.
class LoadQuestionnaire extends ChatEvent {}

/// Event when a user selects an answer from the predefined options.
class AnswerSubmitted extends ChatEvent {
  final String answer;

  const AnswerSubmitted(this.answer);

  @override
  List<Object> get props => [answer];
}

/// Event when a user sends a free-form text message.
class MessageSent extends ChatEvent {
  final String message;

  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}
