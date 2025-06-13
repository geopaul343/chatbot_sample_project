import 'package:equatable/equatable.dart';

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
