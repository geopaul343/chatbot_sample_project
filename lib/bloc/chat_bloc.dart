import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_health_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_health_assistant/message.dart';
import 'package:laennec_ai_health_assistant/questions/screen_questions.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // Hardcoded API key and answers for simplicity in the BLoC context.
  final String _apiKey = "AIzaSyCt71fTFExKKepEv4reR3pkCBiD-o4-hqA";
  final List<List<String>> _predefinedAnswers = [
    [
      "No breathlessness",
      "Slight breathlessness",
      "Moderate breathlessness",
      "Severe breathlessness",
      "Very severe breathlessness",
    ],
    ["Yes", "No"],
    [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "17",
      "18",
      "19",
      "20",
      "21",
      "22",
      "23",
      "24",
      "25",
    ],

    ["Yes", "No"],
    ["Yes", "No"],

    ["Green", "Yellow", "White", "Other"],
    ["Yes", "No"],
  ];

  ChatBloc() : super(const ChatState()) {
    on<LoadQuestionnaire>(_onLoadQuestionnaire);
    on<AnswerSubmitted>(_onAnswerSubmitted);
    on<MessageSent>(_onMessageSent);
  }

  Future<void> _onLoadQuestionnaire(
    LoadQuestionnaire event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isTyping: true));
    await Future.delayed(const Duration(milliseconds: 800));
    final newMessages = List<Message>.from(state.messages)
      ..insert(0, Message(false, screenQuestions[0]));
    emit(
      state.copyWith(
        messages: newMessages,
        isTyping: false,
        showAnswerOptions: true,
        currentQuestionIndex: 0,
        answers: _predefinedAnswers[0],
      ),
    );
  }

  Future<void> _onAnswerSubmitted(
    AnswerSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(selectedAnswer: event.answer));
    await Future.delayed(const Duration(milliseconds: 300));

    final newMessages = List<Message>.from(state.messages)
      ..insert(0, Message(true, event.answer));
    final nextIndex = state.currentQuestionIndex + 1;

    emit(
      state.copyWith(
        messages: newMessages,
        isTyping: true,
        currentQuestionIndex: nextIndex,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    if (nextIndex < screenQuestions.length &&
        nextIndex < _predefinedAnswers.length) {
      final nextQuestionMessages = List<Message>.from(state.messages)
        ..insert(0, Message(false, screenQuestions[nextIndex]));
      emit(
        state.copyWith(
          messages: nextQuestionMessages,
          isTyping: false,
          showAnswerOptions: true,
          clearSelectedAnswer: true,
          answers: _predefinedAnswers[nextIndex],
        ),
      );
    } else {
      final finalMessages = List<Message>.from(state.messages)..insert(
        0,
        Message(
          false,
          "Thank you for your responses! You can now ask me anything.",
        ),
      );
      emit(
        state.copyWith(
          messages: finalMessages,
          isTyping: false,
          showAnswerOptions: false,
          isQuestionnaireComplete: true,
          clearSelectedAnswer: true,
          answers: const [], // Clear answers when questionnaire is complete
        ),
      );
    }
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.isEmpty) return;

    final userMessage = Message(true, event.message);
    final newMessages = List<Message>.from(state.messages)
      ..insert(0, userMessage);

    emit(state.copyWith(messages: newMessages, isTyping: true));

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": event.message},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final botText =
            json["candidates"][0]["content"]["parts"][0]["text"]
                .toString()
                .trim();
        final botMessage = Message(false, botText);
        final finalMessages = List<Message>.from(state.messages)
          ..insert(0, botMessage);
        emit(state.copyWith(messages: finalMessages, isTyping: false));
      } else {
        // Handle API error
        final botMessage = Message(
          false,
          "Sorry, I encountered an error. (Code: ${response.statusCode})",
        );
        final finalMessages = List<Message>.from(state.messages)
          ..insert(0, botMessage);
        emit(state.copyWith(messages: finalMessages, isTyping: false));
      }
    } catch (e) {
      // Handle network or other errors
      final botMessage = Message(
        false,
        "Sorry, something went wrong. Please check your connection.",
      );
      final finalMessages = List<Message>.from(state.messages)
        ..insert(0, botMessage);
      emit(state.copyWith(messages: finalMessages, isTyping: false));
    }
  }
}
