import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_assistant/bloc/voice_bloc/question_event.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/question_state.dart';
import 'package:laennec_ai_assistant/model/answer_option.dart';
import 'package:laennec_ai_assistant/questions/screen_questions.dart';
import 'package:laennec_ai_assistant/secrets.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
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
    [const AnswerOption("Yes"), const AnswerOption("No")],
  ];

  QuestionBloc() : super(QuestionInitial()) {
    on<LoadQuestion>(_onLoadQuestion);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<RestartQuiz>(_onRestartQuiz);
    on<SendGeminiMessage>(_onSendGeminiMessage);
  }

  String _formatAllAnswers(QuestionLoaded state) {
    final List<String> formattedAnswers = [];
    for (
      int i = 0;
      i < state.userAnswers.length && i < screenQuestions.length;
      i++
    ) {
      formattedAnswers.add("Q${i + 1}: ${screenQuestions[i]}");
      formattedAnswers.add("A${i + 1}: ${state.userAnswers[i]}");
      formattedAnswers.add("");
    }
    final totalScore = state.userScores.fold<int>(
      0,
      (prev, score) => prev + score,
    );
    formattedAnswers.add("Total Score: $totalScore");
    return "Here's a summary of your responses:\n\n${formattedAnswers.join('\n')}";
  }

  // Simple matching for voice input
  AnswerOption? _matchAnswer(String spokenText, List<AnswerOption> options) {
    final cleanSpokenText = spokenText.toLowerCase().trim();

    // Check for "repeat" command
    if (cleanSpokenText.contains("repeat")) {
      return const AnswerOption("repeat_question");
    }

    for (final option in options) {
      final cleanOptionText = option.text.toLowerCase();
      if (cleanSpokenText.contains(cleanOptionText)) {
        return option;
      }
    }

    // Synonym matching for Yes/No
    if (options.any((o) => o.text.toLowerCase() == "yes")) {
      const yesWords = ["yes", "yeah", "yep", "yup", "correct", "affirmative"];
      if (yesWords.any((word) => cleanSpokenText.contains(word))) {
        return options.firstWhere((o) => o.text.toLowerCase() == "yes");
      }
    }
    if (options.any((o) => o.text.toLowerCase() == "no")) {
      const noWords = ["no", "nope", "nah", "negative"];
      if (noWords.any((word) => cleanSpokenText.contains(word))) {
        return options.firstWhere((o) => o.text.toLowerCase() == "no");
      }
    }

    return null;
  }

  void _onLoadQuestion(LoadQuestion event, Emitter<QuestionState> emit) {
    emit(
      QuestionLoaded(
        questionIndex: 0,
        questionText: screenQuestions[0],
        answerOptions: predefinedAnswers[0],
      ),
    );
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is! QuestionLoaded) return;
    final currentState = state as QuestionLoaded;

    final matchedAnswer = _matchAnswer(
      event.answer,
      predefinedAnswers[currentState.questionIndex],
    );

    if (matchedAnswer == null) {
      emit(
        currentState.copyWith(
          feedbackMessage: "Sorry, I didn't catch that. Please try again.",
        ),
      );
      return;
    }

    // Handle "repeat" command
    if (matchedAnswer.text == "repeat_question") {
      emit(
        currentState.copyWith(feedbackMessage: "Here is the question again."),
      );
      // We can add logic to re-play the question text via TTS on the UI side
      return;
    }

    final answerText = matchedAnswer.text;
    final selectedOption = matchedAnswer;

    final updatedUserAnswers = List<String>.from(currentState.userAnswers)
      ..add(answerText);
    final updatedUserScores = List<int>.from(currentState.userScores)
      ..add(selectedOption.value ?? 0);
    final newChatHistory = List<Map<String, String>>.from(
      currentState.chatHistory,
    )..add({'user': answerText});

    String? flareUpMessage;
    if (selectedOption.value == 3) {
      flareUpMessage =
          "Your COPD symptoms may be flaring—check your action plan, ensure you're using your maintenance inhalers correctly, and consider contacting your nurse if symptoms persist or worsen.";
    } else if (selectedOption.value != null && selectedOption.value! >= 4) {
      flareUpMessage =
          "Seek urgent help. Call 999 if severely unwell, or contact your GP/nurse immediately.";
    }

    int nextIndex = currentState.questionIndex + 1;
    List<String> nextUserAnswers = updatedUserAnswers;
    List<int> nextUserScores = updatedUserScores;

    // ----- Start of branching logic port -----
    if (currentState.questionIndex == 1) {
      // Reliever inhaler
      if (answerText.toLowerCase() != "yes") {
        nextIndex = 3; // Skip to Q3
        nextUserAnswers.add("N/A (reliever inhaler not used)");
        nextUserScores.add(0);
      }
    } else if (currentState.questionIndex == 3) {
      // Maintenance inhaler
      if (answerText.toLowerCase() == "no") {
        emit(
          currentState.copyWith(
            questionIndex: 4,
            questionText: screenQuestions[4],
            expectingCustomInput: true,
            answerOptions: [],
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
            flareUpMessage: flareUpMessage,
            chatHistory: newChatHistory,
          ),
        );
        return;
      } else {
        nextIndex = 5; // Skip to Q5
        nextUserAnswers.add("N/A (maintenance inhaler was taken)");
        nextUserScores.add(0);
      }
    } else if (currentState.questionIndex == 5) {
      // Sputum changes
      if (answerText.toLowerCase() == "no") {
        nextIndex = 7; // Skip to Q7
        nextUserAnswers.add("N/A (no sputum changes)");
        nextUserScores.add(0);
      }
    } else if (currentState.questionIndex == 7) {
      // Other symptoms
      if (answerText.toLowerCase() == "no") {
        final summary = _formatAllAnswers(
          currentState.copyWith(
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
          ),
        );
        final finalHistory =
            List<Map<String, String>>.from(newChatHistory)
              ..add({'ai': summary})
              ..add({
                'ai':
                    "Thank you for your responses! You can now ask me anything.",
              });
        emit(QuizCompleted(chatHistory: finalHistory));
        return;
      } else {
        // "Yes": Go to question 8 with predefined answers
        final nextIndex = 8;
        final newHistory = List<Map<String, String>>.from(newChatHistory)
          ..add({'ai': screenQuestions[nextIndex]});
        emit(
          currentState.copyWith(
            questionIndex: nextIndex,
            questionText: screenQuestions[nextIndex],
            answerOptions: predefinedAnswers[nextIndex],
            userAnswers: updatedUserAnswers,
            userScores: updatedUserScores,
            flareUpMessage: flareUpMessage,
            chatHistory: newHistory,
          ),
        );
        return;
      }
    }
    // ----- End of branching logic port -----

    if (nextIndex >= screenQuestions.length) {
      final summary = _formatAllAnswers(
        currentState.copyWith(
          userAnswers: nextUserAnswers,
          userScores: nextUserScores,
        ),
      );
      final finalHistory =
          List<Map<String, String>>.from(newChatHistory)
            ..add({'ai': summary})
            ..add({
              'ai':
                  "Thank you for your responses! You can now ask me anything.",
            });
      emit(QuizCompleted(chatHistory: finalHistory));
    } else {
      final newHistory = List<Map<String, String>>.from(newChatHistory)
        ..add({'ai': screenQuestions[nextIndex]});
      emit(
        currentState.copyWith(
          questionIndex: nextIndex,
          questionText: screenQuestions[nextIndex],
          answerOptions:
              predefinedAnswers.length > nextIndex
                  ? predefinedAnswers[nextIndex]
                  : [],
          userAnswers: nextUserAnswers,
          userScores: nextUserScores,
          flareUpMessage: flareUpMessage,
          chatHistory: newHistory,
          feedbackMessage: null,
        ),
      );
    }
  }

  Future<void> _onSendGeminiMessage(
    SendGeminiMessage event,
    Emitter<QuestionState> emit,
  ) async {
    final currentState = state;
    List<Map<String, String>> currentHistory = [];

    if (currentState is QuestionLoaded) {
      if (currentState.expectingCustomInput) {
        final updatedUserAnswers = List<String>.from(currentState.userAnswers)
          ..add(event.message);
        final updatedUserScores = List<int>.from(currentState.userScores)
          ..add(0);
        final newChatHistory = List<Map<String, String>>.from(
          currentState.chatHistory,
        )..add({'user': event.message});

        int nextIndex = currentState.questionIndex + 1;
        if (currentState.questionIndex == 4) {
          // After Q4 text input
          nextIndex = 5;
        }

        if (nextIndex >= screenQuestions.length) {
          final summary = _formatAllAnswers(
            currentState.copyWith(
              userAnswers: updatedUserAnswers,
              userScores: updatedUserScores,
            ),
          );
          final finalHistory =
              List<Map<String, String>>.from(newChatHistory)
                ..add({'ai': summary})
                ..add({
                  'ai':
                      "Thank you for your responses! You can now ask me anything.",
                });
          emit(QuizCompleted(chatHistory: finalHistory));
        } else {
          final newHistory = List<Map<String, String>>.from(newChatHistory)
            ..add({'ai': screenQuestions[nextIndex]});
          emit(
            currentState.copyWith(
              questionIndex: nextIndex,
              questionText: screenQuestions[nextIndex],
              answerOptions: predefinedAnswers[nextIndex],
              userAnswers: updatedUserAnswers,
              userScores: updatedUserScores,
              expectingCustomInput: false,
              chatHistory: newHistory,
            ),
          );
        }
        return;
      }
      currentHistory = currentState.chatHistory;
    } else if (currentState is GeminiResponseLoaded) {
      currentHistory = currentState.chatHistory;
    } else if (currentState is GeminiError) {
      currentHistory = currentState.chatHistory;
    } else if (currentState is QuizCompleted) {
      currentHistory = currentState.chatHistory;
    }

    final newHistory = List<Map<String, String>>.from(currentHistory)
      ..add({'user': event.message});
    emit(GeminiLoading(chatHistory: newHistory));

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey",
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
        final finalHistory = List<Map<String, String>>.from(newHistory)
          ..add({'ai': botText});
        emit(
          GeminiResponseLoaded(response: botText, chatHistory: finalHistory),
        );
      } else {
        emit(
          GeminiError(
            message:
                "Sorry, I encountered an error. (Code: ${response.statusCode})",
            chatHistory: newHistory,
          ),
        );
      }
    } catch (e) {
      emit(
        GeminiError(
          message: "Sorry, something went wrong. Please check your connection.",
          chatHistory: newHistory,
        ),
      );
    }
  }

  void _onRestartQuiz(RestartQuiz event, Emitter<QuestionState> emit) {
    emit(QuestionInitial());
    add(const LoadQuestion());
  }
}
