import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/app_state.dart';
import 'package:laennec_ai_assistant/bloc/voice_bloc/app_event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  // Predefined list of questions for the chat.
  final List<String> _screenQuestions = [
    "How is your breathing today? I'll give you some options to choose from.",
    "Have you used your reliever inhaler today? Please say yes or no.",
    "How many puffs did you take? Please tell me a number from 1 to 25.",
    "Did you take your maintenance inhaler today? Please say yes or no.",
    "Please tell me the reason why you didn't take it.",
    "Have you noticed any sputum changes today? Please say yes or no.",
    "What color is your sputum? I'll give you some color options.",
    "Did you use your oxygen as prescribed last night? Please say yes or no.",
  ];

  // Predefined list of answer options corresponding to each question.
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
    ["Yes", "No"],
    ["Green", "Yellow", "White", "Other"],
    ["Yes", "No"],
  ];

  // Mapping for fuzzy matching of spoken answers to predefined options.
  // Keys are the exact predefined answers, values are lists of possible spoken variations
  // that should match that answer. All values are stored in lowercase.
  final Map<String, List<String>> _fuzzyAnswerMapping = {
    "No breathlessness": ["no", "no breathlessness", "none"],
    "Slight breathlessness": ["slight", "slight breathlessness", "a little"],
    "Moderate breathlessness": ["moderate", "moderate breathlessness", "some"],
    "Severe breathlessness": ["severe", "severe breathlessness", "a lot"],
    "Very severe breathlessness": [
      "very severe",
      "very severe breathlessness",
      "extreme",
    ],
    "Yes": ["yes", "yeah", "yep", "affirmative", "correct"],
    "No": ["no", "nope", "negative", "incorrect"],
    // Puffs (numbers) - handle common spoken forms of numbers
    "1": ["one", "a single", "just one"],
    "2": ["two", "a couple"],
    "3": ["three"],
    "4": ["four"],
    "5": ["five"],
    "6": ["six"],
    "7": ["seven"],
    "8": ["eight"],
    "9": ["nine"],
    "10": ["ten"],
    "11": ["eleven"],
    "12": ["twelve"],
    "13": ["thirteen"],
    "14": ["fourteen"],
    "15": ["fifteen"],
    "16": ["sixteen"],
    "17": ["seventeen"],
    "18": ["eighteen"],
    "19": ["nineteen"],
    "20": ["twenty"],
    "21": ["twenty one", "twenty-one"],
    "22": ["twenty two", "twenty-two"],
    "23": ["twenty three", "twenty-three"],
    "24": ["twenty four", "twenty-four"],
    "25": ["twenty five", "twenty-five"],
    "Green": ["green"],
    "Yellow": ["yellow"],
    "White": ["white"],
    "Other": ["other", "something else", "different"],
  };

  // This is the Gemini AI API key provided by the user.
  final String _apiKey = "AIzaSyCt71fTFExKKepEv4reR3pkCBiD-o4-hqA";

  // Gemini API endpoint URL
  final String _geminiApiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  // Current index to keep track of which question is being asked.
  int _currentQuestionIndex = 0;

  // History of chat messages for display
  List<Map<String, String>> _chatHistory = [];

  // Constructor for the QuestionBloc.
  QuestionBloc() : super(QuestionInitial()) {
    // Register event handlers.
    on<LoadQuestion>(_onLoadQuestion);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<RestartQuiz>(_onRestartQuiz);
    on<SendGeminiMessage>(_onSendGeminiMessage);
  }

  /// Handles the `LoadQuestion` event.
  /// Emits a `QuestionLoaded` state with the current question and its options,
  /// or a `QuizCompleted` state if all questions have been answered.
  void _onLoadQuestion(LoadQuestion event, Emitter<QuestionState> emit) {
    if (_currentQuestionIndex < _screenQuestions.length) {
      final questionText = _screenQuestions[_currentQuestionIndex];
      final answerOptions = _predefinedAnswers[_currentQuestionIndex];
      _chatHistory.add({
        'role': 'model',
        'text': questionText,
      }); // Add question to chat history
      emit(
        QuestionLoaded(
          questionIndex: _currentQuestionIndex,
          questionText: questionText,
          answerOptions: answerOptions,
          chatHistory: List.from(_chatHistory), // Pass a copy of history
        ),
      );
    } else {
      emit(QuizCompleted(chatHistory: List.from(_chatHistory)));
    }
  }

  /// Handles the `SubmitAnswer` event.
  /// Validates the user's answer against the predefined options for the current question.
  /// If correct, moves to the next question.
  /// If incorrect, re-emits the same question with a feedback message.
  void _onSubmitAnswer(SubmitAnswer event, Emitter<QuestionState> emit) {
    // Prevent submitting answers if quiz is already completed.
    if (_currentQuestionIndex >= _screenQuestions.length) {
      emit(QuizCompleted(chatHistory: List.from(_chatHistory)));
      return;
    }

    final String rawUserAnswer = event.answer.trim();
    final String normalizedUserAnswer =
        rawUserAnswer.toLowerCase(); // Normalize user input
    _chatHistory.add({
      'role': 'user',
      'text': rawUserAnswer,
    }); // Add user answer to chat history

    bool isCorrect = false;
    String? matchedPredefinedAnswer;

    // Get the predefined answer options for the current question
    final List<String> currentPredefinedOptions =
        _predefinedAnswers[_currentQuestionIndex];

    // Check if the user's answer matches any of the predefined options, or their fuzzy variations
    for (String predefinedOption in currentPredefinedOptions) {
      // Get the list of fuzzy variations for this predefined option
      final List<String>? fuzzyVariations =
          _fuzzyAnswerMapping[predefinedOption];

      // Check if the normalized user answer is an exact match for the predefined option,
      // or if it matches any of the fuzzy variations
      if (normalizedUserAnswer == predefinedOption.toLowerCase() ||
          (fuzzyVariations != null &&
              fuzzyVariations.contains(normalizedUserAnswer))) {
        isCorrect = true;
        matchedPredefinedAnswer =
            predefinedOption; // Store the exact predefined answer
        break; // Found a match, no need to check further
      }
    }

    if (isCorrect) {
      // If the answer is correct, move to the next question.
      _currentQuestionIndex++;
      if (_currentQuestionIndex < _screenQuestions.length) {
        final questionText = _screenQuestions[_currentQuestionIndex];
        final answerOptions = _predefinedAnswers[_currentQuestionIndex];
        _chatHistory.add({
          'role': 'model',
          'text': "Understood. $matchedPredefinedAnswer. " + questionText,
        });
        emit(
          QuestionLoaded(
            questionIndex: _currentQuestionIndex,
            questionText: questionText,
            answerOptions: answerOptions,
            feedbackMessage: null, // Clear previous feedback
            chatHistory: List.from(_chatHistory),
          ),
        );
      } else {
        // All questions answered, emit QuizCompleted state.
        emit(QuizCompleted(chatHistory: List.from(_chatHistory)));
      }
    } else {
      // If the answer is wrong, re-emit the current question with a feedback message.
      final feedbackMessage =
          "Your answer '$rawUserAnswer' is not in our options. Please choose from: ${_predefinedAnswers[_currentQuestionIndex].join(', ')}";
      _chatHistory.add({
        'role': 'model',
        'text': feedbackMessage,
      }); // Add feedback to chat history
      emit(
        QuestionLoaded(
          questionIndex: _currentQuestionIndex,
          questionText: _screenQuestions[_currentQuestionIndex],
          answerOptions: _predefinedAnswers[_currentQuestionIndex],
          feedbackMessage: feedbackMessage,
          chatHistory: List.from(_chatHistory),
        ),
      );
    }
  }

  /// Handles the `RestartQuiz` event.
  /// Resets the question index and loads the first question again.
  void _onRestartQuiz(RestartQuiz event, Emitter<QuestionState> emit) {
    _currentQuestionIndex = 0;
    _chatHistory.clear(); // Clear chat history on restart
    add(const LoadQuestion()); // Trigger loading the first question
  }

  /// Handles the `SendGeminiMessage` event for free-form chat.
  Future<void> _onSendGeminiMessage(
    SendGeminiMessage event,
    Emitter<QuestionState> emit,
  ) async {
    _chatHistory.add({'role': 'user', 'text': event.message});
    emit(GeminiLoading(chatHistory: List.from(_chatHistory)));

    try {
      final payload = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": event.message},
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse("$_geminiApiUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        final String? geminiResponse =
            result['candidates']?[0]['content']?['parts']?[0]?['text'];

        if (geminiResponse != null) {
          _chatHistory.add({'role': 'model', 'text': geminiResponse});
          emit(
            GeminiResponseLoaded(
              response: geminiResponse,
              chatHistory: List.from(_chatHistory),
            ),
          );
        } else {
          _chatHistory.add({
            'role': 'model',
            'text': "Error: Could not get a valid response from Gemini.",
          });
          emit(
            GeminiError(
              message: "Could not get a valid response from Gemini.",
              chatHistory: List.from(_chatHistory),
            ),
          );
        }
      } else {
        _chatHistory.add({
          'role': 'model',
          'text': "Error: API call failed with status ${response.statusCode}",
        });
        emit(
          GeminiError(
            message: "API call failed: ${response.statusCode}",
            chatHistory: List.from(_chatHistory),
          ),
        );
      }
    } catch (e) {
      _chatHistory.add({
        'role': 'model',
        'text': "Error: An exception occurred: $e",
      });
      emit(
        GeminiError(
          message: "An error occurred: $e",
          chatHistory: List.from(_chatHistory),
        ),
      );
    }
  }
}
