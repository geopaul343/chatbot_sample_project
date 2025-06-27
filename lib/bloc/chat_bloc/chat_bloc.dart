import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_state.dart';
import 'package:laennec_ai_assistant/model/answer_option.dart';
import 'package:laennec_ai_assistant/model/message.dart';
import 'package:laennec_ai_assistant/questions/screen_questions.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // Hardcoded API key and answers for simplicity in the BLoC context.
  final String _apiKey = "AIzaSyCt71fTFExKKepEv4reR3pkCBiD-o4-hqA";
  final List<List<AnswerOption>> predefinedAnswers = [
    [
      const AnswerOption("No issues", value: 0),
      const AnswerOption("No breathlessness", value: 0),
      const AnswerOption("Slight breathlessness", value: 1),
      const AnswerOption("Moderate breathlessness", value: 2),
      const AnswerOption("Severe breathlessness", value: 3),
      const AnswerOption("Very severe breathlessness", value: 4),
      const AnswerOption("Worsening", value: 5),
    ],
    [const AnswerOption("Yes"), const AnswerOption("No")],
    [
      const AnswerOption("1"),
      const AnswerOption("2"),
      const AnswerOption("3"),
      const AnswerOption("4"),
      const AnswerOption("5"),
      const AnswerOption("6"),
      const AnswerOption("7"),
      const AnswerOption("8"),
      const AnswerOption("9"),
      const AnswerOption("10"),
      const AnswerOption("11"),
      const AnswerOption("12"),
      const AnswerOption("13"),
      const AnswerOption("14"),
      const AnswerOption("15"),
      const AnswerOption("16"),
      const AnswerOption("17"),
      const AnswerOption("18"),
      const AnswerOption("19"),
      const AnswerOption("20"),
      const AnswerOption("21"),
      const AnswerOption("22"),
      const AnswerOption("23"),
      const AnswerOption("24"),
      const AnswerOption("25"),
    ],
    [const AnswerOption("Yes"), const AnswerOption("No")],
    [const AnswerOption("Yes"), const AnswerOption("No")],
    [const AnswerOption("Yes"), const AnswerOption("No")],
    [
      const AnswerOption("Green"),
      const AnswerOption("Yellow"),
      const AnswerOption("White"),
      const AnswerOption("Other"),
    ],
    [const AnswerOption("Yes"), const AnswerOption("No")],
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
        userScores: [], // Initialize user scores
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
    final totalScore = state.userScores.fold<int>(
      0,
      (prev, score) => prev + score,
    );
    formattedAnswers.add("Total Score: $totalScore");
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

    // Find the selected answer option to get its value
    final selectedOption = predefinedAnswers[state.currentQuestionIndex]
        .firstWhere(
          (option) => option.text == event.answer,
          orElse: () => const AnswerOption("", value: 0),
        );

    // Add answer to user answers collection
    final updatedUserAnswers = List<String>.from(state.userAnswers)
      ..add(event.answer);
    final updatedUserScores = List<int>.from(state.userScores)
      ..add(selectedOption.value ?? 0);

    String? flareUpMessage;
    if (selectedOption.value == 3) {
      flareUpMessage =
          "Your COPD symptoms may be flaring—check your action plan, ensure you're using your maintenance inhalers correctly, and consider contacting your nurse if symptoms persist or worsen.";
    } else if (selectedOption.value != null && selectedOption.value! >= 4) {
      flareUpMessage =
          "Seek urgent help. Call 999 if severely unwell, or contact your GP/nurse immediately.";
    }

    // Special handling for question index 1 (reliever inhaler question)
    if (state.currentQuestionIndex == 1) {
      emit(
        state.copyWith(
          messages: newMessages,
          isTyping: true,
          userAnswers: updatedUserAnswers,
          userScores: updatedUserScores,
          flareUpMessage: flareUpMessage,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (event.answer.toLowerCase() == "yes") {
        // Go to question 2 (puffs count)
        final nextIndex = 2;
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
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
          ),
        );
      } else {
        // "No": Skip question 2 and go to question 3
        final nextIndex = 3;

        // Add placeholder for skipped question 2
        final updatedUserAnswersWithSkip = List<String>.from(updatedUserAnswers)
          ..add("N/A (reliever inhaler not used)");
        final updatedUserScoresWithSkip = List<int>.from(updatedUserScores)
          ..add(0); // No score for skipped question

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
            userScores: updatedUserScoresWithSkip,
          ),
        );
      }
      return; // Stop further execution
    }

    // Special handling for question index 5 (sputum changes)
    if (state.currentQuestionIndex == 5) {
      if (event.answer.toLowerCase() == "no") {
        emit(
          state.copyWith(
            messages: newMessages,
            isTyping: true,
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
            flareUpMessage: flareUpMessage,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        // "No": Skip question 6 and go to question 7
        final nextIndex = 7;

        // Add placeholder for skipped question 6
        final updatedUserAnswersWithSkip = List<String>.from(updatedUserAnswers)
          ..add("N/A (no sputum changes)");
        final updatedUserScoresWithSkip = List<int>.from(updatedUserScores)
          ..add(0); // No score for skipped question

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
            userScores: updatedUserScoresWithSkip,
          ),
        );
        return; // Stop further execution
      }
    }

    // Special handling for question index 7
    if (state.currentQuestionIndex == 7) {
      if (event.answer.toLowerCase() == "no") {
        // "No": End the questionnaire
        final finalMessages =
            List<Message>.from(newMessages)
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
            userScores: updatedUserScores,
            flareUpMessage: flareUpMessage,
          ),
        );
        return; // Stop further execution
      } else {
        // "Yes": Go to question 8 (free text)
        emit(
          state.copyWith(
            messages: newMessages,
            isTyping: true,
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
            flareUpMessage: flareUpMessage,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        final nextIndex = 8;
        final nextQuestionMessages = List<Message>.from(state.messages)
          ..insert(0, Message(false, screenQuestions[nextIndex]));
        emit(
          state.copyWith(
            messages: nextQuestionMessages,
            isTyping: false,
            showAnswerOptions: false, // Hide answer options
            expectingCustomInput: true, // Set flag for custom input
            currentQuestionIndex: nextIndex,
            clearSelectedAnswer: true,
            answers: const [],
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
          ),
        );
        return;
      }
    }

    // Special handling for question index 3 (maintenance inhaler question)
    if (state.currentQuestionIndex == 3) {
      emit(
        state.copyWith(
          messages: newMessages,
          isTyping: true,
          userAnswers: updatedUserAnswers,
          userScores: updatedUserScores,
          flareUpMessage: flareUpMessage,
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
            userScores: updatedUserScores,
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
          final updatedUserScoresWithSkip = List<int>.from(updatedUserScores)
            ..add(0); // No score for skipped question

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
              userScores: updatedUserScoresWithSkip,
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
              userScores: updatedUserScores,
              flareUpMessage: flareUpMessage,
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
        userScores: updatedUserScores,
        flareUpMessage: flareUpMessage,
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
          userScores: updatedUserScores,
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
          userScores: updatedUserScores,
          flareUpMessage: flareUpMessage,
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

    // Special case: If we're expecting custom input
    if (state.expectingCustomInput) {
      // Add the custom reason to user answers
      final updatedUserAnswers = List<String>.from(state.userAnswers)
        ..add(event.message);
      final updatedUserScores = List<int>.from(state.userScores)
        ..add(0); // No score for custom input

      emit(
        state.copyWith(
          messages: newMessages,
          isTyping: true,
          userAnswers: updatedUserAnswers,
          userScores: updatedUserScores,
          expectingCustomInput: false,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      // Determine next question
      int nextIndex = state.currentQuestionIndex + 1;
      if (state.currentQuestionIndex == 4) {
        nextIndex = 5; // After Q4 free text, go to Q5
      }

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
            userScores: updatedUserScores,
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
            userScores: updatedUserScores,
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

// SplashBloc for handling splash screen functionality
class SplashBloc extends Bloc<AppEvent, AppState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashUpdateStatus>(_onSplashUpdateStatus);
    on<SplashShowError>(_onSplashShowError);
    on<SplashCompleted>(_onSplashCompleted);
  }

  void _onSplashStarted(SplashStarted event, Emitter<AppState> emit) {
    emit(const SplashLoading('Initializing...'));
  }

  void _onSplashUpdateStatus(SplashUpdateStatus event, Emitter<AppState> emit) {
    emit(SplashLoading(event.statusMessage));
  }

  void _onSplashShowError(SplashShowError event, Emitter<AppState> emit) {
    emit(SplashError(event.errorMessage));
  }

  void _onSplashCompleted(SplashCompleted event, Emitter<AppState> emit) {
    emit(const SplashComplete());
  }
}
