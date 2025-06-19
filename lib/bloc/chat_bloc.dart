import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_health_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_health_assistant/model/message.dart';
import 'package:laennec_ai_health_assistant/questions/screen_questions.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // Hardcoded API key and answers for simplicity in the BLoC context.
  final String _apiKey = "AIzaSyCt71fTFExKKepEv4reR3pkCBiD-o4-hqA";
  final List<List<String>> predefinedAnswers = [
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
        answers: predefinedAnswers[0],
        userAnswers: [], // Initialize user answers tracking
      ),
    );
  }

  String _formatAllAnswers() {
    final List<String> formattedAnswers = [];
    for (
      int i = 0;
      i < state.userAnswers.length && i < screenQuestions.length;
      i++
    ) {
      formattedAnswers.add("Q${i + 1}: ${screenQuestions[i]}");
      formattedAnswers.add("A${i + 1}: ${state.userAnswers[i]}");
      formattedAnswers.add(""); // Empty line for spacing
    }
    return "Here's a summary of your responses:\n\n${formattedAnswers.join('\n')}";
  }

  Future<void> _onAnswerSubmitted(
    AnswerSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(selectedAnswer: event.answer));
    await Future.delayed(const Duration(milliseconds: 300));

    final newMessages = List<Message>.from(state.messages)
      ..insert(0, Message(true, event.answer));

    // Add answer to user answers collection
    final updatedUserAnswers = List<String>.from(state.userAnswers)
      ..add(event.answer);

    // Special handling for question index 3 (maintenance inhaler question)
    if (state.currentQuestionIndex == 3) {
      emit(
        state.copyWith(
          messages: newMessages,
          isTyping: true,
          userAnswers: updatedUserAnswers,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (event.answer.toLowerCase() == "no") {
        // If "No", ask question 4 with chat input enabled
        final nextQuestionMessages = List<Message>.from(state.messages)
          ..insert(0, Message(false, screenQuestions[4]));
        emit(
          state.copyWith(
            messages: nextQuestionMessages,
            isTyping: false,
            showAnswerOptions: false, // Hide answer options for free text input
            expectingCustomInput: true, // Set flag for custom input
            currentQuestionIndex: 4,
            clearSelectedAnswer: true,
            answers: const [],
            userAnswers: updatedUserAnswers,
          ),
        );
      } else {
        // If "Yes", skip question 4 and go to question 5
        final nextIndex = 5; // Skip question 4
        if (nextIndex < screenQuestions.length &&
            nextIndex < predefinedAnswers.length) {
          // Add placeholder for skipped question 4
          final updatedUserAnswersWithSkip = List<String>.from(
            updatedUserAnswers,
          )..add("N/A (maintenance inhaler was taken)");

          final nextQuestionMessages = List<Message>.from(state.messages)
            ..insert(0, Message(false, screenQuestions[nextIndex]));
          emit(
            state.copyWith(
              messages: nextQuestionMessages,
              isTyping: false,
              showAnswerOptions: true,
              currentQuestionIndex: nextIndex,
              clearSelectedAnswer: true,
              answers: predefinedAnswers[nextIndex],
              userAnswers: updatedUserAnswersWithSkip,
            ),
          );
        } else {
          // End questionnaire if we've reached the end
          final finalMessages =
              List<Message>.from(state.messages)
                ..insert(0, Message(false, _formatAllAnswers()))
                ..insert(
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
              answers: const [],
              userAnswers: updatedUserAnswers,
            ),
          );
        }
      }
      return;
    }

    final nextIndex = state.currentQuestionIndex + 1;

    emit(
      state.copyWith(
        messages: newMessages,
        isTyping: true,
        currentQuestionIndex: nextIndex,
        userAnswers: updatedUserAnswers,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    if (nextIndex < screenQuestions.length &&
        nextIndex < predefinedAnswers.length) {
      final nextQuestionMessages = List<Message>.from(state.messages)
        ..insert(0, Message(false, screenQuestions[nextIndex]));
      emit(
        state.copyWith(
          messages: nextQuestionMessages,
          isTyping: false,
          showAnswerOptions: true,
          clearSelectedAnswer: true,
          answers: predefinedAnswers[nextIndex],
          userAnswers: updatedUserAnswers,
        ),
      );
    } else {
      // Show all answers summary before ending questionnaire
      final finalMessages =
          List<Message>.from(state.messages)
            ..insert(0, Message(false, _formatAllAnswers()))
            ..insert(
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
          answers: const [],
          userAnswers: updatedUserAnswers,
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

    // Special case: If we're expecting custom input (reason for not taking maintenance inhaler)
    if (state.expectingCustomInput && state.currentQuestionIndex == 4) {
      // Add the custom reason to user answers
      final updatedUserAnswers = List<String>.from(state.userAnswers)
        ..add(event.message);

      emit(
        state.copyWith(
          messages: newMessages,
          isTyping: true,
          userAnswers: updatedUserAnswers,
          expectingCustomInput: false,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      // Continue to question 5
      final nextIndex = 5;
      if (nextIndex < screenQuestions.length &&
          nextIndex < predefinedAnswers.length) {
        final nextQuestionMessages = List<Message>.from(state.messages)
          ..insert(0, Message(false, screenQuestions[nextIndex]));
        emit(
          state.copyWith(
            messages: nextQuestionMessages,
            isTyping: false,
            showAnswerOptions: true,
            currentQuestionIndex: nextIndex,
            answers: predefinedAnswers[nextIndex],
            userAnswers: updatedUserAnswers,
          ),
        );
      } else {
        // End questionnaire and show all answers
        final finalMessages =
            List<Message>.from(state.messages)
              ..insert(0, Message(false, _formatAllAnswers()))
              ..insert(
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
            answers: const [],
            userAnswers: updatedUserAnswers,
          ),
        );
      }
      return;
    }

    // Check if questionnaire is complete before allowing AI chat
    if (!state.isQuestionnaireComplete) {
      // If questionnaire is not complete, don't allow regular chat
      final errorMessage = Message(
        false,
        "Please complete the questionnaire first.",
      );
      final errorMessages = List<Message>.from(state.messages)
        ..insert(0, errorMessage);
      emit(state.copyWith(messages: errorMessages));
      return;
    }

    // Regular AI chat for completed questionnaire
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
